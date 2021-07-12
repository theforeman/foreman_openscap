module Types
  class OvalPolicy < BaseObject
    description 'An OVAL Policy'
    model_class ::ForemanOpenscap::OvalPolicy

    include ::Types::Concerns::MetaField

    global_id_field :id
    timestamps
    field :name, String
    field :description, String
    field :period, String
    field :weekday, String
    field :day_of_month, String
    field :cron_line, String
    belongs_to :oval_content, ::Types::OvalContent

    has_many :hostgroups, ::Types::Hostgroup

    def self.graphql_definition
      super.tap { |type| type.instance_variable_set(:@name, 'ForemanOpenscap::OvalPolicy') }
    end
  end
end
