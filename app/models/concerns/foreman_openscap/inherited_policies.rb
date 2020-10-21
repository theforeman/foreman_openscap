module ForemanOpenscap
  module InheritedPolicies
    def find_inherited_policies(policy_attr)
      return [] unless parent

      ancestors.reduce([]) do |policies, hostgroup|
        policies += hostgroup.public_send(policy_attr)
      end.uniq
    end
  end
end
