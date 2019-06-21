module Types
  class TailoringFile < BaseObject
    description 'A Tailoring File'
    model_class ::ForemanOpenscap::TailoringFile

    global_id_field :id
    timestamps
    field :name, String
    field :original_filename, String
    field :digest, String
    field :scap_file, String
  end
end
