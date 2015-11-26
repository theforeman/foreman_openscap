module ForemanOpenscap
  module SmartProxyExtensions
    extend ActiveSupport::Concern

    included do
      has_many :openscap_hostgroups, :foreign_key => 'openscap_proxy_id', :class_name => "::Hostgroup"
      has_many :openscap_hosts, :foreign_key => 'openscap_proxy_id', :class_name => "::Host"
      has_many :arf_reports, :foreign_key => 'openscap_proxy_id', :class_name => "ForemanOpenscap::ArfReport"
      PORT_MATCH = /:(\d+)\z/
      after_destroy :delete_associated_arf_reports
    end

    def port
      url.match(PORT_MATCH)[1]
    end

    private

    def delete_associated_arf_reports
      ForemanOpenscap::ArfReport.where(:openscap_proxy_id => id).delete_all
    end
  end
end
