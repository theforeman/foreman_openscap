require 'test_plugin_helper'

module Queries
  class TailoringFileQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query tailoringFile($id: String!){
          tailoringFile(id: $id) {
            id
            createdAt
            updatedAt
            name
            digest
            originalFilename
          }
        }
      GRAPHQL
    end

    let(:tailoring_file) { FactoryBot.create(:tailoring_file) }
    let(:global_id) { Foreman::GlobalId.for(tailoring_file) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['tailoringFile'] }

    test 'fetch tailoring file by global id' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal tailoring_file.name, data['name']
      assert_equal tailoring_file.digest, data['digest']
    end
  end
end
