module ForemanOpenscap
  module OpenscapProxyCoreExtensions
    extend ActiveSupport::Concern

    included do
      validate :openscap_proxy_has_feature
      validate :scap_client_class_present
      after_save :update_scap_client
    end

    def update_scap_client
      update_scap_client_params if changed.include?('openscap_proxy_id')
    end

    def update_scap_client_params
      model_match = self.class.name.underscore.match(/\Ahostgroup\z/) ? "hostgroup" : "fqdn"
      scap_params = find_scap_client.class_params
      server_lookup_key = scap_params.find { |param| param.key == "server" }
      port_lookup_key = scap_params.find { |param| param.key == "port" }
      pairs = scap_client_lookup_values_for([server_lookup_key, port_lookup_key], model_match)
      if openscap_proxy_id
        mapping = { "server" => openscap_proxy.hostname, "port" => openscap_proxy.port }
        update_scap_client_lookup_values(pairs, model_match, mapping)
      else
        destroy_scap_client_lookup_values pairs
      end
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

    def destroy_scap_client_lookup_values(pairs)
      pairs.values.map(&:destroy)
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

    def find_scap_client
      Puppetclass.find_by_name("foreman_scap_client")
    end

    def lookup_matcher(model_match)
      model_match == "fqdn" ? "#{model_match}=#{name}" : "#{model_match}=#{title}"
    end

    def openscap_proxy_has_feature
      errors.add(:openscap_proxy_id, _("must have Openscap feature")) if openscap_proxy_id && !openscap_proxy.has_feature?("Openscap")
    end

    def scap_client_class_present
      if openscap_proxy_id_changed? && openscap_proxy_id
        errors.add(:openscap_proxy_id, _("Puppet class 'foreman_scap_client' not found, make sure it is imported from Puppet master")) unless find_scap_client
      end
    end
  end
end
