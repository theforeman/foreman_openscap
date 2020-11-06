module ForemanOpenscap
  module DataStreamContent
    extend ActiveSupport::Concern

    included do
      validates_with ForemanOpenscap::DataStreamValidator

      after_save :create_profiles, :if => lambda { |ds_content| ds_content.scap_file_previously_changed? }
      before_destroy ActiveRecord::Base::EnsureNotUsedBy.new(:policies)
    end

    def proxy_url
      @proxy_url ||= SmartProxy.with_features('Openscap').find do |proxy|
        available = ProxyAPI::AvailableProxy.new(:url => proxy.url)
        available.available?
      end.try(:url)
      @proxy_url
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
  end
end
