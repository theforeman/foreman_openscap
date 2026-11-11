module ForemanOpenscap
  module StoredScapFile
    extend ActiveSupport::Concern

    included do
      has_one_attached :scap_document

      around_save :store_scap_document
      after_save :clear_pending_scap_file
      after_commit :forget_uploaded_scap_documents
      after_rollback :discard_uploaded_scap_documents
    end

    # Keep the existing byte-oriented interface used by controllers and proxies.
    # SQL remains a fallback for records not yet copied by the migration task.
    def scap_file
      @scap_file_assigned ? @pending_scap_file : stored_scap_file
    end

    def scap_file=(content)
      @scap_file_assigned = true
      @pending_scap_file = content
    end

    def scap_file_changed?
      (@scap_file_assigned && @pending_scap_file != stored_scap_file) || super
    end

    def scap_file_previously_changed?
      saved_change_to_digest? || super
    end

    def reload(*args)
      super.tap do
        clear_pending_scap_file
        @stored_scap_document = nil
      end
    end

    private

    def stored_scap_file
      return self[:scap_file] unless scap_document.attached?

      blob = scap_document.blob
      if !@stored_scap_document || @stored_scap_document.first != blob.id
        @stored_scap_document = [blob.id, blob.download]
      end
      @stored_scap_document.last
    end

    def store_scap_document
      return yield unless @scap_file_assigned && scap_file_changed?

      saved = false
      blob = nil
      # A savepoint also rolls back the Blob row if an outer transaction rescues
      # a failed model save and subsequently commits other work.
      self.class.transaction(:requires_new => true) do
        filename = File.basename(original_filename.presence || 'openscap.xml')
        blob = VerifiedDocument.upload(@pending_scap_file, filename)
        (@uploaded_scap_documents ||= []) << blob
        self.scap_document = blob
        saved = yield
        raise ActiveRecord::Rollback unless saved
      end
      VerifiedDocument.discard(blob) if blob && !saved
      saved
    rescue StandardError
      VerifiedDocument.discard(blob) if blob
      raise
    end

    def clear_pending_scap_file
      @scap_file_assigned = false
      @pending_scap_file = nil
    end

    def forget_uploaded_scap_documents
      @uploaded_scap_documents = []
    end

    def discard_uploaded_scap_documents
      Array(@uploaded_scap_documents).each { |blob| VerifiedDocument.discard(blob) }
      # A savepoint rollback can leave an earlier save in the outer transaction
      # intact. Keep ownership until the outer transaction commits or rolls back.
    end
  end
end
