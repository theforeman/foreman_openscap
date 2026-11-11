module ForemanOpenscap
  class DocumentMigration
    MODELS = [ScapContent, TailoringFile].freeze

    def initialize(apply: false, cleanup: false, output: $stdout)
      @apply = apply
      @cleanup = cleanup
      @output = output
    end

    def run
      counts = { :eligible => 0, :migrated => 0, :cleaned => 0, :already_stored => 0, :failed => 0 }
      MODELS.each do |model|
        # An operator migration must include every organization and location.
        # Datastream XML can be large: do not load 1,000 SQL payloads at once.
        model.unscoped.find_each(:batch_size => 1) do |record|
          @cleanup ? cleanup(record, counts) : migrate(record, counts)
        end
      end
      @output.puts("#{@apply ? 'Apply' : 'Preview'} #{@cleanup ? 'cleanup' : 'copy'}: #{counts.inspect}")
      counts
    end

    private

    def cleanup(record, counts)
      record.class.transaction(:requires_new => true) do
        record.lock! if @apply
        next if record[:scap_file].nil?

        unless record.scap_document.attached?
          raise ActiveStorage::IntegrityError, 'Document has not been migrated'
        end
        # A legacy column may contain an older version after a user edits an
        # already migrated document. The attachment must match the current digest.
        record.scap_document.blob.open do |file|
          unless Digest::SHA256.file(file.path).hexdigest == record[:digest]
            raise ActiveStorage::IntegrityError, 'Stored document does not match the current digest'
          end
        end
        if @apply
          record.update_columns(:scap_file => nil)
          counts[:cleaned] += 1
        else
          counts[:eligible] += 1
        end
      end
    rescue StandardError => error
      counts[:failed] += 1
      @output.puts("Failed #{record.class.name} ##{record.id}: #{error.class}")
    end

    def migrate(record, counts)
      blob = nil
      if @apply
        record.class.transaction(:requires_new => true) do
          record.lock!
          if record.scap_document.attached?
            counts[:already_stored] += 1
          else
            content = legacy_content(record)
            blob = VerifiedDocument.upload(content, File.basename(record.original_filename.presence || 'openscap.xml'))
            # Do not save the model: that would validate through a Smart Proxy
            # and rebuild profiles. The source bytes and digest stay unchanged.
            ActiveStorage::Attachment.create!(:record => record, :name => 'scap_document', :blob => blob)
            counts[:migrated] += 1
          end
        end
      elsif record.scap_document.attached?
        counts[:already_stored] += 1
      else
        legacy_content(record)
        counts[:eligible] += 1
      end
    rescue StandardError => error
      VerifiedDocument.discard(blob) if blob
      counts[:failed] += 1
      @output.puts("Failed #{record.class.name} ##{record.id}: #{error.class}")
    end

    def legacy_content(record)
      content = record[:scap_file]
      unless content.present? && Digest::SHA256.hexdigest(content) == record[:digest]
        raise ActiveStorage::IntegrityError, 'Legacy document is missing or does not match its digest'
      end
      content
    end
  end
end
