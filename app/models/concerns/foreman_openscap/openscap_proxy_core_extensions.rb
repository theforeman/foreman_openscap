module ForemanOpenscap
  module OpenscapProxyCoreExtensions
    extend ActiveSupport::Concern

    included do
      validate :openscap_proxy_has_feature
    end

    def update_scap_client_params(proxy_id)
      new_proxy = SmartProxy.find proxy_id
      model_match = self.class.name.underscore.match(/\Ahostgroup\z/) ? "hostgroup" : "fqdn"
      puppetclass = Puppetclass.find_by_name("foreman_scap_client")
      fail _("Puppetclass 'foreman_scap_client' not found, make sure it is imported form Puppetmaster") if puppetclass.nil?
      scap_params = puppetclass.class_params
      server_lookup_key = scap_params.find { |param| param.key == "server" }
      port_lookup_key = scap_params.find { |param| param.key == "port" }
      pairs = scap_client_lookup_values_for([server_lookup_key, port_lookup_key], model_match)
      mapping = { "server" => new_proxy.hostname, "port" => new_proxy.port }
      update_scap_client_lookup_values(pairs, model_match, mapping)
    end

    def inherited_openscap_proxy_id
      inherited_ancestry_attribute(:openscap_proxy_id)
    end

    private

    def scap_client_lookup_values_for(lookup_keys, model_match)
      lookup_keys.inject({}) do |result, key|
        result[key] = key.lookup_values.find { |value| value.match == "#{lookup_matcher(model_match)}" }
        result
      end
    end

    def update_scap_client_lookup_values(pairs, model_match, mapping)
      pairs.each do |k, v|
        if v.nil?
          LookupValue.create(:match => lookup_matcher(model_match), :value => mapping[k.key], :lookup_key_id => k.id)
        else
          v.value = mapping[k.key]
          v.save
        end
      end
    end

    def lookup_matcher(model_match)
      model_match == "fqdn" ? "#{model_match}=#{name}" : "#{model_match}=#{title}"
    end

    def openscap_proxy_has_feature
      return true unless openscap_proxy_id
      openscap_proxy.has_feature? "Openscap"
    end
  end
end
