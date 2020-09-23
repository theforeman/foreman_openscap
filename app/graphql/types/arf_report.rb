module Types
  class ArfReport < Types::Report
    description 'An Arf Report'
    model_class ::ForemanOpenscap::ArfReport

    global_id_field :id
    field :passed, Integer
    field :failed, Integer
    field :othered, Integer
  end
end
