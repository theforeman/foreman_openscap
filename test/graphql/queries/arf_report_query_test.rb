require 'test_plugin_helper'

module Queries
  class ArfReportQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query arfReport($id: String!){
          arfReport(id: $id) {
            id
            createdAt
            updatedAt
            failed
            passed
            othered
            logs {
              nodes{
                result
                message {
                  value
                  description
                  rationale
                  scapReferences
                }
                source {
                  value
                }
              }
            }
          }
        }
      GRAPHQL
    end

    let(:policy) { FactoryBot.create(:policy) }
    let(:global_id) { Foreman::GlobalId.for(arf_report) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['arfReport'] }
    let(:arf_report) do
      file_fixture = JSON.parse File.read("#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report.json")
      params = file_fixture.with_indifferent_access.merge(:policy_id => policy.id, :metrics => { :passed => 5, :failed => 8, :othered => 4 })
      ForemanOpenscap::ArfReport.create_arf(FactoryBot.create(:asset), nil, params)
    end

    test 'fetch arf report by global id' do
      assert_empty result['errors']
      assert_equal global_id, data['id']
      assert_equal arf_report.failed, data['failed']
      assert_equal arf_report.passed, data['passed']
      log = data['logs']['nodes'].first
      assert log['result']
      assert log['source']['value']
      msg = log['message']
      assert msg['value']
      assert msg['description']
      assert msg['rationale']
      assert msg['scapReferences']
    end
  end
end
