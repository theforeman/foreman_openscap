require 'test_plugin_helper'

class HostgroupExtensionsTest < ActiveSupport::TestCase
  test "should remove all linked assets on hostgroup destroy" do
    hostgroup = FactoryBot.create(:hostgroup)
    FactoryBot.create_list(:asset, 3, :assetable_id => hostgroup.id, :assetable_type => 'Hostgroup')
    asset_scope = ::ForemanOpenscap::Asset.where(:assetable_id => hostgroup.id, :assetable_type => 'Hostgroup')
    assert_difference("asset_scope.count", -3) { hostgroup.destroy }
  end
end
