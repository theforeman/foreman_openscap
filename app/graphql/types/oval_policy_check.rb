module Types
  class OvalPolicyCheck < BaseObject
    description 'A check that contains inforrmation about whether a particual prerequisite for OVAL policy deployment is configured correctly'
    model_class ::ForemanOpenscap::Oval::SetupCheck

    global_id_field :id
    field :title, String, :null => false
    field :result, String, :null => false
    field :fail_msg, String, :null => true
    field :errors, Types::RawJson, :null => true
  end
end
