module ForemanOpenscap
  class ConfigNameService
    attr_reader :configs

    def initialize
      @configs = [
        ForemanOpenscap::ClientConfig::Ansible.new,
        ForemanOpenscap::ClientConfig::Puppet.new,
        ForemanOpenscap::ClientConfig::Manual.new
      ]
    end

    def config_for(type)
      @configs.find { |config| config.type == type }
    end

    def all_except(type)
      @configs.reject { |config| config.type == type }
    end

    def all_available_except(type)
      all_except(type).select(&:available?)
    end

    def all_available_with_overrides_except(type)
      all_available_except(type).select(&:managed_overrides?)
    end
  end
end
