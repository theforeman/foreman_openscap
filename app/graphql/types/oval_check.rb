module Types
  class OvalCheck < GraphQL::Schema::Object
    description 'A check that contains information about whether a particual prerequisite for OVAL policy deployment is configured correctly'

    field :id, String, null: false
    field :title, String, null: false
    field :fail_msg, String, null: true
    field :errors, ::Types::RawJson, null: true
    field :result, String, null: false
  end
end
