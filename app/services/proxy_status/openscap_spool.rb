module ProxyStatus
  class OpenscapSpool < Base
    def spool_status
      fetch_proxy_data do
        api.spool_status
      end
    end

    def self.humanized_name
      'Openscap'
    end
  end
end
