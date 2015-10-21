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
  end
end
