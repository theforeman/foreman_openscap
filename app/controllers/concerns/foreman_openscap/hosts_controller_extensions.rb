module ForemanOpenscap
  module HostsControllerExtensions
    def self.prepended(base)
      base::AJAX_REQUESTS << 'openscap_proxy_changed'
    end

    def process_hostgroup
      @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i > 0
      return head(:not_found) unless @hostgroup
      @openscap_proxy = @hostgroup.openscap_proxy
      super
    end
  end
end
