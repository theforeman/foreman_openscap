module Types
  class OvalContent < BaseObject
    description 'An OVAL Content'
    model_class ::ForemanOpenscap::OvalContent

    global_id_field :id
    timestamps
    field :name, String
    field :digest, String
    field :original_filename, String
    field :url, String

    def self.graphql_definition
      super.tap { |type| type.instance_variable_set(:@name, 'ForemanOpenscap::OvalContent') }
    end
  end
end
