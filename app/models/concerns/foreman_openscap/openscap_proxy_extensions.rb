module ForemanOpenscap
  module OpenscapProxyExtensions
    extend ActiveSupport::Concern

    included do
      belongs_to :openscap_proxy, :class_name => "SmartProxy"
    end

    def openscap_proxy_api
      return @openscap_api if @openscap_api
      proxy_url = openscap_proxy.url if openscap_proxy
      raise ::Foreman::Exception.new(N_("No OpenSCAP proxy found for %{class} with %{id}"), { :class => self.class, :id => id }) unless proxy_url
      @openscap_api = ::ProxyAPI::Openscap.new(:url => proxy_url)
    end
  end
end
