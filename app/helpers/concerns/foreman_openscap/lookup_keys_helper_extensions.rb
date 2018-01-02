module ForemanOpenscap
  module LookupKeysHelperExtensions
    def overridable_lookup_keys(klass, obj)
      return [] if klass.name == "foreman_scap_client"
      super klass, obj
    end
  end
end
