module Mutations
  module OvalContents
    class Sync < ::Mutations::UpdateMutation
      description 'Sync OVAL Content from url'
      graphql_name 'SyncOvalContent'
      resource_class ::ForemanOpenscap::OvalContent

      field :oval_content, ::Types::OvalContent, null: false

      def resolve(params)
        oval_content = load_object_by(id: params[:id])
        authorize!(oval_content, :edit)
        oval_content.fetch_remote_content
        User.as(context[:current_user]) do
          errors = oval_content.errors.none? && oval_content.save ? [] : map_errors_to_path(oval_content)
          {
            :oval_content => oval_content,
            :errors => errors,
          }
        end
      end
    end
  end
end
