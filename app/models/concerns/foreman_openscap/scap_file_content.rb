module ForemanOpenscap
  module ScapFileContent
    require 'digest/sha2'

    extend ActiveSupport::Concern

    included do
      before_validation :redigest, :if => lambda { |file_content| file_content.persisted? && file_content.scap_file_changed? }
    end

    def digest
      self[:digest] ||= Digest::SHA256.hexdigest(scap_file.to_s) if scap_file
    end

    private

    def redigest
      self[:digest] = Digest::SHA256.hexdigest(scap_file.to_s) if scap_file
    end
  end
end
