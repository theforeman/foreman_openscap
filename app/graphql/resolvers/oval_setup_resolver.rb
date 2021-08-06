module Resolvers
  class OvalSetupResolver < BaseResolver
    type [::Types::OvalPolicyCheck], null: false

    def resolve(**_args)
      check_collection = ::ForemanOpenscap::Oval::Setup.new.run(true)
      check_collection.checks
    end
  end
end
