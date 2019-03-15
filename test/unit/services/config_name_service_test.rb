require 'test_plugin_helper'

class ConfigNameServiceTest < ActiveSupport::TestCase
  setup do
    @name_service = ForemanOpenscap::ConfigNameService.new
  end

  test 'should find config for Puppet' do
    assert @name_service.config_for(:puppet).is_a?(ForemanOpenscap::ClientConfig::Puppet)
  end

  test 'should find config for Ansible' do
    assert @name_service.config_for(:ansible).is_a?(ForemanOpenscap::ClientConfig::Ansible)
  end

  test 'should find config for Manual' do
    assert @name_service.config_for(:manual).is_a?(ForemanOpenscap::ClientConfig::Manual)
  end

  test 'should find all except Manual' do
    configs = @name_service.all_except(:manual)
    assert_equal 2, configs.size
    refute configs.map(&:type).include?(:manual)
  end

  test 'should find all available except Manual' do
    ForemanOpenscap::ClientConfig::Ansible.any_instance.stubs(:available?).returns(false)
    configs = @name_service.all_available_except(:manual)
    assert_equal 1, configs.size
    assert_equal :puppet, configs.first.type
  end

  test 'should find all available with overrides except Puppet' do
    ForemanOpenscap::ClientConfig::Ansible.any_instance.stubs(:available?).returns(true)
    configs = @name_service.all_available_with_overrides_except(:puppet)
    assert_equal 1, configs.size
    assert_equal :ansible, configs.first.type
  end
end
