module ForemanOpenscap
  module ScapFileContent
    require 'digest/sha2'

    extend ActiveSupport::Concern

    included do
      validates :digest, :presence => true
      validates :scap_file, :presence => true

      before_validation :redigest, :if => lambda { |file_content| !file_content.persisted? || file_content.scap_file_changed? }
    end

    def digest
      self[:digest] ||= Digest::SHA256.hexdigest(scap_file.to_s)
    end

    private

    def redigest
      self[:digest] = Digest::SHA256.hexdigest(scap_file.to_s)
    end
  end
end
