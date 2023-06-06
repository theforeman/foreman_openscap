module ForemanOpenscap
  module HostsAndHostgroupsControllerExtensions
    extend ActiveSupport::Concern
    included do
      before_action :detect_proxy_without_scap, :only => :edit
    end

    def detect_proxy_without_scap
      unless openscap_proxy_id.nil?
        error = _("The %s proxy does not have Openscap feature enabled. Either set correct OpenSCAP Proxy or unset it.") % openscap_proxy_id[:name]
        return error(error, :now => true) unless scap_enabled_proxy?(openscap_proxy_id)
      end
    end

    def scap_enabled_proxy?(proxy_id)
      SmartProxy.find_by!(id: proxy_id).feature_names.include?('Openscap')
    end

    def openscap_proxy_id
      @host.try(:openscap_proxy) || @hostgroup.try(:openscap_proxy)
    end
  end
end
