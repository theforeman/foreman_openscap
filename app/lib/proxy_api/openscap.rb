module ::ProxyAPI
  class Openscap < ::ProxyAPI::Resource
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
      @url = args[:url] + '/compliance/'
      super args
      @connect_params[:headers][:content_type] = :xml
      @connect_params[:timeout] = timeout
    end

    def fetch_policies_for_scap_content(scap_file)
      parse(post(scap_file, "scap_content/policies"))
    end

    def fetch_profiles_for_tailoring_file(scap_file)
      parse(post(scap_file, "tailoring_file/profiles"))
    end

    def validate_scap_file(scap_file, type)
      parse(post(scap_file, "scap_file/validator/#{type}"))
    rescue RestClient::RequestTimeout => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Request timed out. Please try increasing Settings -> proxy_request_timeout"))
    rescue RestClient::ResourceNotFound => e
      raise ::ProxyAPI::ProxyException.new(url, e,
                                           N_("Could not validate %s. Please make sure you have appropriate proxy version to use this functionality") % type.humanize)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e,
                                           N_("Could not validate %{file_type}. Error %{error}") % { :file_type => type.humanize, :error => e.message })
    end

    def policy_html_guide(scap_file, policy)
      guide = parse(post(scap_file, "scap_content/guide/#{policy}"))
      guide['html']
    end

    def arf_report_html(report, cname)
      begin
        @connect_params[:headers] = { :accept => 'application/html' }
        get "/arf/#{report.id}/#{cname}/#{report.reported_at.to_i}/#{report.policy_arf_report.digest}/html"
      rescue => e
        raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to get HTML version of requested report from Smart Proxy"))
      end
    end

    def arf_report_bzip(report, cname)
      begin
        @connect_params[:headers] = { :content_type => 'application/arf-bzip2', :content_encoding => 'x-bzip2' }
        get "/arf/#{report.id}/#{cname}/#{report.reported_at.to_i}/#{report.policy_arf_report.digest}/xml"
      rescue => e
        raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to get XML version of requested report from Smart Proxy"))
      end
    end

    def destroy_report(report, cname)
      begin
        parse(delete("arf/#{report.id}/#{cname}/#{report.reported_at.to_i}/#{report.policy_arf_report.digest}"))
      rescue => e
        msg = "Failed to destroy arf report with id #{report.id} on Smart Proxy, cause: #{e.message}"
        logger.error msg
        report.errors.add(:base, msg)
        false
      end
    end

    def spool_status
      parse(get('spool_errors'))
    rescue => e
      msg = "Failed to get spool status from proxy, cause: #{e.message}"
      logger.error msg
      {}
    end

    private

    def timeout
      Setting[:proxy_request_timeout] && Setting[:proxy_request_timeout] > 120 ? Setting[:proxy_request_timeout] : 120
    end
  end
end
