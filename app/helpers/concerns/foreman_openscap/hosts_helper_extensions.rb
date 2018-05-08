module ForemanOpenscap
  module HostsHelperExtensions
    def multiple_actions
      super + [[_('Assign Compliance Policy'), select_multiple_hosts_policies_path],
                                       [_('Unassign Compliance Policy'), disassociate_multiple_hosts_policies_path],
                                       [_('Change OpenSCAP Proxy'), select_multiple_openscap_proxy_hosts_path]]
    end

    def name_column(record)
      record.nil? ? _('Host is deleted') : super(record)
    end
  end
end
