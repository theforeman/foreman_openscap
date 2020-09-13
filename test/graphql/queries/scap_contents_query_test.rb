require 'test_plugin_helper'

module Queries
  class ScapContentsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query {
          scapContents {
            totalCount
            pageInfo {
              startCursor
              endCursor
              hasNextPage
              hasPreviousPage
            }
            edges {
              cursor
              node {
                id
                name
                digest
                originalFilename
              }
            }
          }
        }
      GRAPHQL
    end

    let(:data) { result['data']['scapContents'] }

    setup do
      FactoryBot.create(:scap_content)
    end

    test 'fetch tailoring files' do
      assert_empty result['errors']

      expected_count = ForemanOpenscap::ScapContent.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
