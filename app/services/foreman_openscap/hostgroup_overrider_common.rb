module ForemanOpenscap
  module HostgroupOverriderCommon
    def add_overrides(collection, host_or_hg, config)
      model_match = host_or_hg.class.name.underscore =~ /\Ahostgroup\z/ ? "hostgroup" : "fqdn"
      collection.where(:override => true).find_each do |override|
        return unless host_or_hg.openscap_proxy && (url = host_or_hg.openscap_proxy.url).present?

        openscap_proxy_uri = URI.parse(url)
        case override.key
        when config.server_param
          lookup_value = LookupValue.where(:match => "#{model_match}=#{host_or_hg.to_label}", :lookup_key_id => override.id).first_or_initialize
          lookup_value.update_attribute(:value, openscap_proxy_uri.host)
        when config.port_param
          lookup_value = LookupValue.where(:match => "#{model_match}=#{host_or_hg.to_label}", :lookup_key_id => override.id).first_or_initialize
          lookup_value.update_attribute(:value, openscap_proxy_uri.port)
        end
      end
    end

    def remove_overrides(collection, hostgroup, config)
      collection.where(:override => true).find_each do |override|
        if override.key == config.server_param || override.key == config.port_param
          LookupValue.find_by(:match => "hostgroup=#{hostgroup.to_label}", :lookup_key_id => override.id)&.destroy
        end
      end
    end
  end
end
