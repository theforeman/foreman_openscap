module ::ProxyAPI
  class Openscap < ::ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + '/compliance/'
      super args
      @connect_params[:headers].merge!(:content_type => :xml)
    end

    def fetch_policies_for_scap_content(scap_file)
      parse(post(scap_file, "scap_content/policies"))
    end

    def validate_scap_content(scap_file)
      parse(post(scap_file, "scap_content/validator"))
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
        logger.error "Failed to destroy arf report with id #{report.id} on Smart Proxy"
        logger.debug e.backtrace.join("\n\t")
        false
      end
    end
  end
end
