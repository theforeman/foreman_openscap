module Mutations
  module OvalPolicies
    class Update < UpdateMutation
      graphql_name 'UpdateOvalPolicyMutation'
      description 'Updates an OVAL Policy'
      resource_class ::ForemanOpenscap::OvalPolicy

      argument :name, String, required: false
      argument :description, String, required: false
      argument :cron_line, String, required: false

      field :oval_policy, ::Types::OvalPolicy, 'The OVAL policy.', null: true
    end
  end
end
