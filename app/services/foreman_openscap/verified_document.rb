require 'base64'
require 'digest'
require 'stringio'

module ForemanOpenscap
  # Upload before attaching: a failed upload must not replace a working document.
  class VerifiedDocument
    def self.upload(content, filename)
      blob = ActiveStorage::Blob.create_before_direct_upload!(
        :filename => filename,
        :content_type => 'application/xml',
        :byte_size => content.bytesize,
        :checksum => Base64.strict_encode64(Digest::MD5.digest(content))
      )
      blob.upload(StringIO.new(content), :identify => false)
      blob.open do |file|
        unless file.size == content.bytesize && Digest::SHA256.file(file.path).hexdigest == Digest::SHA256.hexdigest(content)
          raise ActiveStorage::IntegrityError, 'OpenSCAP document verification failed'
        end
      end
      blob.save!
      blob
    rescue StandardError
      discard(blob) if blob
      raise
    end

    # Also remove objects whose Blob INSERT has already been rolled back.
    # Call only for new blobs owned by this operation, never for existing uploads.
    def self.discard(blob)
      return if blob.attachments.exists?

      blob.service.delete(blob.key)
      blob.destroy! if blob.persisted?
    rescue StandardError => error
      Rails.logger.error("OpenSCAP document cleanup failed for blob #{blob.key}: #{error.class}")
    end
  end
end
