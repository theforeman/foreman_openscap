require 'test_plugin_helper'

module Mutations
  module OvalContents
    class SyncOvalContentTest < ActiveSupport::TestCase
      setup do
        @query = <<-GRAPHQL
          mutation SyncOvalContent($id: ID!) {
            syncOvalContent(input: { id: $id }) {
              ovalContent {
                id
                name
                changedAt
              }
              errors {
                path
                message
              }
            }
          }
        GRAPHQL

        @initial_content = 'initial_content'
        ForemanOpenscap::Oval::SyncOvalContents.any_instance.stubs(:fetch_content_blob).returns(@initial_content)
        @oval_content = FactoryBot.create(:oval_content, :url => 'https://example.com')
        @content_id = Foreman::GlobalId.for(@oval_content)
        @variables = { :id => @content_id }
        @context = { current_user: FactoryBot.create(:user, :admin) }
      end

      test 'should sync oval content' do
        updated_content = 'updated_content'
        ForemanOpenscap::Oval::SyncOvalContents.any_instance.stubs(:fetch_content_blob).returns(updated_content)
        result = ForemanGraphqlSchema.execute(@query, variables: @variables, context: @context)
        assert_empty result['data']['syncOvalContent']['errors']
        @oval_content.reload
        assert_equal updated_content, @oval_content.scap_file
      end

      test 'should show error' do
        ForemanOpenscap::Oval::SyncOvalContents.any_instance.stubs(:fetch_content_blob).returns(nil)
        result = ForemanGraphqlSchema.execute(@query, variables: @variables, context: @context)
        assert_not_empty result['data']['syncOvalContent']['errors']
      end
    end
  end
end
