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

    def create_profiles
      fetch_profiles.each do |key, title|
        create_or_update_profile key, title
      end
    end

    def create_or_update_profile(profile_id, title)
      profile = ScapContentProfile.find_by(:profile_id => profile_id, "#{self.class.to_s.demodulize.underscore}_id".to_sym => id)
      return ScapContentProfile.create(:profile_id => profile_id, :title => title, "#{self.class.to_s.demodulize.underscore}_id".to_sym => id) unless profile
      profile.update(:title => title) unless profile.title == title
      profile
    end

    private

    def redigest
      self[:digest] = Digest::SHA256.hexdigest(scap_file.to_s)
    end
  end
end
