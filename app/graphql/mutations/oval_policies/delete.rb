module Mutations
  module OvalPolicies
    class Delete < DeleteMutation
      graphql_name 'DeleteOvalPolicyMutation'
      description 'Deletes an OVAL Policy'
      resource_class ::ForemanOpenscap::OvalPolicy
    end
  end
end
