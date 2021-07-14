require 'test_plugin_helper'

module Queries
  class OvalContentQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query($id:String!) {
          ovalContent(id: $id) {
            id
            name
            originalFilename
            url
          }
        }
      GRAPHQL
    end

    let(:oval_content) { FactoryBot.create(:oval_content) }

    let(:global_id) { Foreman::GlobalId.for(oval_content) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['ovalContent'] }

    test 'should return OVAL Content' do
      assert_equal global_id, data['id']
      assert_equal oval_content.name, data['name']
    end
  end
end
