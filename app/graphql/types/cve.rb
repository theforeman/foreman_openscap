module Types
  class Cve < BaseObject
    description 'A CVE'
    model_class ::ForemanOpenscap::Cve

    global_id_field :id
    field :ref_id, String
    field :ref_url, String
    field :has_errata, Boolean
    field :definition_id, String
    has_many :hosts, Types::Host

    def self.graphql_definition
      super.tap { |type| type.instance_variable_set(:@name, 'ForemanOpenscap::Cve') }
    end
  end
end
