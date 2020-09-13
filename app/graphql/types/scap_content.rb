module Types
  class ScapContent < BaseObject
    description 'A Scap Content'
    model_class ::ForemanOpenscap::ScapContent

    global_id_field :id
    timestamps
    field :title, String
    field :original_filename, String
    field :digest, String
    field :scap_file, String
  end
end
