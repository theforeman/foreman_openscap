module ForemanOpenscap
  module OpenscapProxyCoreExtensions
    extend ActiveSupport::Concern

    included do
      validate :openscap_proxy_has_feature
      after_save :update_scap_client
    end

    def update_scap_client
      name_service = ConfigNameService.new
      if openscap_proxy_id_previously_changed?
        model_match = self.class.name.underscore =~ /\Ahostgroup\z/ ? "hostgroup" : "fqdn"
        name_service.all_available_except(:manual).each do |config|
          update_client_params(model_match, config)
        end
      end
    end

    def update_client_params(model_match, config)
      client_item = config.find_config_item self.public_send(config.collection_method)
      return unless client_item
      lookup_keys = client_item.public_send(config.override_method_name)
      server_key = lookup_keys.find { |param| param.key == config.server_param }
      port_key = lookup_keys.find { |param| param.key == config.port_param }
      pairs = scap_client_lookup_values_for([server_key, port_key], model_match)
      if openscap_proxy_id
        mapping = { config.server_param => openscap_proxy.hostname, config.port_param => openscap_proxy.port }
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
        result[key] = key.lookup_values.find { |value| value.match == lookup_matcher(model_match).to_s }
        result
      end
    end

    def destroy_scap_client_lookup_values(pairs)
      pairs.values.compact.map(&:destroy)
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
      errors.add(:openscap_proxy_id, _("must have Openscap feature")) if openscap_proxy && !openscap_proxy.has_feature?("Openscap")
    end
  end
end
