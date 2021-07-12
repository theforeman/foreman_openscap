module Mutations
  module OvalContents
    class Delete < DeleteMutation
      graphql_name 'DeleteOvalContentMutation'
      description 'Deletes an OVAL Content'
      resource_class ::ForemanOpenscap::OvalContent
    end
  end
end
