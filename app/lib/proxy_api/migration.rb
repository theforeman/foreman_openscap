module ::ProxyAPI
  class Migration < ::ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + '/compliance-importer'
      super args
      @connect_params[:headers].merge!(:content_type => 'text/xml', :content_encoding => 'x-bzip2', :multipart => true)
    end

    def migrate_arf_report(arf_file, host_name, policy_id, date)
      parse(post(arf_file, "/arf/#{host_name}/#{policy_id}/#{date}"))
    end
  end
end
