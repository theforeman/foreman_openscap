module ForemanOpenscap
  module LookupKeysHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :overridable_lookup_keys, :scap
    end

    def overridable_lookup_keys_with_scap(klass, obj)
      return [] if klass.name == "foreman_scap_client"
      overridable_lookup_keys_without_scap klass, obj
    end
  end
end
