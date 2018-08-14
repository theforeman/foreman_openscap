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

    def select_multiple_openscap_proxy
      find_multiple
    end

    def update_multiple_openscap_proxy
      if (id = params['smart_proxy']['id'])
        find_multiple
        smart_proxy = ::SmartProxy.find(id)
        @hosts.each do |host|
          host.openscap_proxy = smart_proxy
          host.save!
        end
        success _("Updated hosts: Assigned with OpenSCAP Proxy: %s") % smart_proxy.name
        redirect_to hosts_path
      else
        error _('No OpenSCAP Proxy selected.')
        redirect_to(select_multiple_openscap_proxy_hosts_path)
      end
    end

    private

    def action_permission
      case params[:action]
      when 'select_multiple_openscap_proxy', 'update_multiple_openscap_proxy'
        :edit
      else
        super
      end
    end
  end
end
