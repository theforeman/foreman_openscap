require 'test_plugin_helper'

module Queries
  class ArfReportsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query {
          arfReports {
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
                passed
                failed
                othered
              }
            }
          }
        }
      GRAPHQL
    end

    let(:data) { result['data']['arfReports'] }

    setup do
      host = FactoryBot.create(:host)
      FactoryBot.create(:arf_report, :host_id => host.id)
    end

    test 'fetch arf reports' do
      assert_empty result['errors']

      expected_count = ForemanOpenscap::ArfReport.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
    end
  end
end
