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
    end

    def available?
      begin
        return true if @features.include?('openscap')
      rescue *HTTP_ERRORS
        return false
      end
    end
  end
end
