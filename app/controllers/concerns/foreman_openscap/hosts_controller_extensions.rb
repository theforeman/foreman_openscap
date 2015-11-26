module ForemanOpenscap
  module HostsControllerExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :process_hostgroup, :openscap
      self::AJAX_REQUESTS << 'openscap_proxy_changed'
    end

    def process_hostgroup_with_openscap
      @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i > 0
      return head(:not_found) unless @hostgroup
      @openscap_proxy = @hostgroup.openscap_proxy
      process_hostgroup_without_openscap
    end
  end
end
