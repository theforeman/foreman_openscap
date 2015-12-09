module ForemanOpenscap
  module OpenscapProxyExtensions
    extend ActiveSupport::Concern

    included do
      belongs_to :openscap_proxy, :class_name => "SmartProxy"
      attr_accessible :openscap_proxy_id
    end

    def openscap_proxy_api
      return @openscap_api if @openscap_api
      proxy_url = openscap_proxy.url
      fail(_("No openscap proxy found for %s") % name) unless proxy_url
      @openscap_api = ::ProxyAPI::Openscap.new(:url => proxy_url)
    end
  end
end
