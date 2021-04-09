require 'test_plugin_helper'

module Queries
  class OvalContentsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        ovalContents {
          totalCount
          nodes {
            id
            name
          }
        }
      }
      GRAPHQL
    end

    let(:data) { result['data']['ovalContents'] }

    setup do
      FactoryBot.create_list(:oval_content, 2)
    end

    test 'should fetch oval contentes' do
      assert_empty result['errors']

      expected_count = ForemanOpenscap::OvalContent.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['nodes'].count
    end
  end
end
