module Types
  class OvalContent < BaseObject
    description 'An OVAL Content'
    model_class ::ForemanOpenscap::OvalContent

    include ::Types::Concerns::MetaField

    global_id_field :id
    timestamps
    field :name, String
    field :digest, String
    field :original_filename, String
    field :url, String
    field :changed_at, GraphQL::Types::ISO8601DateTime

    def self.graphql_definition
      super.tap { |type| type.instance_variable_set(:@name, 'ForemanOpenscap::OvalContent') }
    end
  end
end
