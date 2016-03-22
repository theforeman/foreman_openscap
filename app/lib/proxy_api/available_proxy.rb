module ::ProxyAPI
  class AvailableProxy

    HTTP_ERRORS = [
      EOFError,
      Errno::ECONNRESET,
      Errno::EINVAL,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Timeout::Error
    ]

    def initialize(args)
      @features = ::ProxyAPI::Features.new(args).features
      @versions = ::ProxyAPI::Version.new(args).proxy_versions['modules']
    end

    def available?
      begin
        return true if (@features.include?('openscap') && minimum_version)
      rescue *HTTP_ERRORS
        return false
      end
      false
    end

    private

    def openscap_proxy_version
      @versions['openscap'] if @versions['openscap']
    end

    def minimum_version
      return false unless openscap_proxy_version
      openscap_proxy_version.to_f >= 0.5
    end
  end
end
