module ForemanOpenscap
  class OpenscapProxyAssignedVersionCheck < OpenscapProxyVersionCheck
    def initialize(host)
      @host = host
      super()
    end

    private

    def get_openscap_proxies
      @host.openscap_proxy ? [@host.openscap_proxy] : []
    end
  end
end
