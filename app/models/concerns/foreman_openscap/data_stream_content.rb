module ForemanOpenscap
  module DataStreamContent
    require 'digest/sha2'

    extend ActiveSupport::Concern

    included do
      validates :digest, :presence => true
      validates :scap_file, :presence => true

      validates_with ForemanOpenscap::DataStreamValidator

      after_save :create_profiles

      before_validation :redigest, :if => lambda { |ds_content| ds_content.persisted? && ds_content.scap_file_changed? }
      before_destroy ActiveRecord::Base::EnsureNotUsedBy.new(:policies)
    end

    def proxy_url
      @proxy_url ||= SmartProxy.with_features('Openscap').find do |proxy|
        available = ProxyAPI::AvailableProxy.new(:url => proxy.url)
        available.available?
      end.try(:url)
      @proxy_url
    end

    def digest
      self[:digest] ||= Digest::SHA256.hexdigest(scap_file.to_s)
    end

    private

    def redigest
      self[:digest] = Digest::SHA256.hexdigest(scap_file.to_s)
    end

    def create_profiles
      fetch_profiles.each do |key, title|
        ScapContentProfile.where(:profile_id => key, :title => title, "#{self.class.to_s.demodulize.underscore}_id".to_sym => id).first_or_create
      end
    end
  end
end
