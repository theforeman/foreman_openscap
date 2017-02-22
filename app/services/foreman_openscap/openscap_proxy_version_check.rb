module ForemanOpenscap
  class OpenscapProxyVersionCheck

    def initialize
      @versions = {}
      @message = ''
      @down = []
    end

    def run
      @versions = openscap_proxy_versions.select do |key, value|
        Gem::Version.new(value) < Gem::Version.new("0.6.1")
      end
      self
    end

    def pass?
      !any_outdated? && !any_unreachable?
    end

    def any_outdated?
      !@versions.empty?
    end

    def any_unreachable?
      !@down.empty?
    end

    def message
      if pass?
        @message
      else
        build_message
      end
    end

    private

    def build_message
      @message = _('This feature is temporarily disabled. ')
      @message << _('The following Smart Proxies need to be updated to unlock the feature: %s. ') % @versions.keys.to_sentence if any_outdated?
      @message << _('The following proxies could not be reached: %s. Please make sure they are available so Foreman can check their versions.') % @down.to_sentence if any_unreachable?
      @message
    end

    def get_openscap_proxies
      SmartProxy.with_features "Openscap"
    end

    def openscap_proxy_versions
      get_openscap_proxies.inject({}) do |memo, proxy|
        begin
          status = ProxyStatus::Version.new(proxy).version
          openscap_version = status["modules"]["openscap"]
          memo[proxy.name] = openscap_version
        rescue Foreman::WrappedException
          @down << proxy.name
        end
        memo
      end
    end
  end
end
