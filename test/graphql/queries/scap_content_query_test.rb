equire 'test_plugin_helper'

module Queries
  class ScapContentQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query scapContent($id: String!){
          scapContent(id: $id) {
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

    let(:scap_content) { FactoryBot.create(:scap_content) }
    let(:global_id) { Foreman::GlobalId.for(scap_content) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['scapContent'] }

    test 'fetch scap content by global id' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal scap_content.name, data['name']
      assert_equal scap_content.digest, data['digest']
    end
  end
end
