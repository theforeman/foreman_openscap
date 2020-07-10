require 'test_plugin_helper'

module Queries
  class TailoringFilesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query {
          tailoringFiles {
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

    let(:data) { result['data']['tailoringFiles'] }

    setup do
      FactoryBot.create(:tailoring_file)
    end

    test 'fetch tailoring files' do
      assert_empty result['errors']

      expected_count = ForemanOpenscap::TailoringFile.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
