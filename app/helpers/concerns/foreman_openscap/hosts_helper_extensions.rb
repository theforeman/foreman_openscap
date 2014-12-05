module ForemanOpenscap
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :multiple_actions, :scap
    end

    def multiple_actions_with_scap
      multiple_actions_without_scap << [_('Assign Compliance Policy'), select_multiple_hosts_scaptimony_policies_path]
    end
  end
end
