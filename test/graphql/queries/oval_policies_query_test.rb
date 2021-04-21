require 'test_plugin_helper'

module Queries
  class OvalPoliciesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        ovalPolicies {
          totalCount
          nodes {
            id
            name
          }
        }
      }
      GRAPHQL
    end

    let(:data) { result['data']['ovalPolicies'] }

    setup do
      FactoryBot.create_list(:oval_policy, 2, :oval_content => FactoryBot.create(:oval_content))
    end

    test 'should fetch oval policies' do
      assert_empty result['errors']

      expected_count = ForemanOpenscap::OvalPolicy.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['nodes'].count
    end
  end
end
