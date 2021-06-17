module Mutations
  module OvalPolicies
    class Create < CreateMutation
      description 'Creates a new OVAL Policy'
      graphql_name 'CreateOvalPolicyMutation'

      resource_class ::ForemanOpenscap::OvalPolicy

      argument :name, String
      argument :description, String, required: false
      argument :period, String
      argument :weekday, String, required: false
      argument :day_of_month, Integer, required: false
      argument :cron_line, String, required: false
      argument :oval_content_id, ID, loads: Types::OvalContent, required: false
      argument :hostgroup_ids, [ID], loads: Types::Hostgroup, as: :hostgroups, required: false

      field :oval_policy, Types::OvalPolicy, 'The new OVAL Policy.', null: true

      def result_key
        :oval_policy
      end

      private

      def initialize_object(params)
        hg_ids = params.delete(:hostgroups).pluck(:id)
        policy = super params
        policy.hostgroup_ids = hg_ids
        policy
      end
    end
  end
end
