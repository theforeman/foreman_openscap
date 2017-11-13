module ::ProxyAPI
  class AvailableProxy
    HTTP_ERRORS = [
      EOFError,
      Errno::ECONNRESET,
      Errno::EINVAL,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Timeout::Error,
      ProxyAPI::ProxyException
    ].freeze

    def initialize(args)
      @args = args
    end

    def available?
      begin
        return true if has_scap_feature? && minimum_version
      rescue *HTTP_ERRORS
        return false
      end
      false
    end

    private

    def has_scap_feature?
      @features ||= ::ProxyAPI::Features.new(@args).features
      @features.include?('openscap')
    end

    def openscap_proxy_version
      @versions ||= ::ProxyAPI::Version.new(@args).proxy_versions['modules']
      @versions['openscap'] if @versions && @versions['openscap']
    end

    def minimum_version
      return false unless openscap_proxy_version
      openscap_proxy_version.to_f >= 0.5
    end
  end
end
