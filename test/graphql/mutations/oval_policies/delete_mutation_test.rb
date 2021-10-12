require 'test_plugin_helper'

module Mutations
  module OvalPolicies
    class DeleteMutationTest < ActiveSupport::TestCase
      let(:policy) { FactoryBot.create(:oval_policy, :oval_content => FactoryBot.create(:oval_content)) }
      let(:policy_id) { Foreman::GlobalId.for(policy) }
      let(:variables) do
        {
          id: policy_id,
        }
      end
      let(:query) do
        <<-GRAPHQL
        mutation DeleteOvalPolicyMutation($id:ID!){
          deleteOvalPolicy(input:{id:$id}) {
            id
            errors {
              message
              path
            }
          }
        }
        GRAPHQL
      end

      context 'with admin user' do
        let(:user) { FactoryBot.create(:user, :admin) }

        test 'should delete oval policy' do
          context = { current_user: user }

          policy

          assert_difference('::ForemanOpenscap::OvalPolicy.count', -1) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['deleteOvalPolicy']['errors']
            assert_equal policy_id, result['data']['deleteOvalPolicy']['id']
          end
          assert_equal user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        setup do
          policy
          @user = setup_user 'view', 'oval_policies'
        end

        test 'should not delete oval policy' do
          context = { current_user: @user }

          assert_difference('ForemanOpenscap::OvalPolicy.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
            assert_includes result['errors'].map { |error| error['message'] }.to_sentence, 'Unauthorized.'
          end
        end
      end
    end
  end
end
