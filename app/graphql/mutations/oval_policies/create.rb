module Mutations
  module OvalPolicies
    class Create < ::Mutations::BaseMutation
      description 'Creates a new OVAL Policy'
      graphql_name 'CreateOvalPolicyMutation'

      resource_class ::ForemanOpenscap::OvalPolicy

      argument :name, String
      argument :description, String, required: false
      argument :period, String
      argument :weekday, String, required: false
      argument :day_of_month, Integer, required: false
      argument :cron_line, String, required: false
      argument :oval_content_id, Integer, required: true
      argument :hostgroup_ids, [Integer], required: false

      field :oval_policy, Types::OvalPolicy, 'The new OVAL Policy.', null: true
      field :check_collection, [Types::OvalCheck], 'A collection of checks to detect OVAL policy configuration error', null: false

      def resolve(hostgroup_ids:, **params)
        policy = ::ForemanOpenscap::OvalPolicy.new params
        validate_object(policy)
        authorize!(policy, :create)
        check_collection = ::ForemanOpenscap::Oval::Configure.new.assign(policy, hostgroup_ids, ::Hostgroup)
        {
          :oval_policy => policy,
          :check_collection => check_collection.checks
        }
      end
    end
  end
end
