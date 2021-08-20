require 'test_plugin_helper'

class ForemanOpenscap::Oval::SetupCheckTest < ActiveSupport::TestCase
  test 'should show error message with filled in data' do
    check = ::ForemanOpenscap::Oval::SetupCheck.new(
      :id => :test_check,
      :title => _("Will it pass?"),
      :fail_msg => ->(hash) { "There was an error in #{hash[:name]}, you need to #{hash[:action]}" }
    )

    check.fail_with!(:name => 'your engine', :action => 'run')
    assert_equal 'There was an error in your engine, you need to run', check.fail_msg
  end

  test 'should show error message when it is a string' do
    msg = "Do not panic"
    check = ::ForemanOpenscap::Oval::SetupCheck.new(
      :id => :test_check,
      :title => _("Will it pass?"),
      :fail_msg => msg
    )
    check.fail!
    assert_equal msg, check.fail_msg
  end

  test 'should not show error message when check not failed' do
    check = ::ForemanOpenscap::Oval::SetupCheck.new(
      :id => :test_check,
      :title => _("Will it pass?"),
      :fail_msg => 'foo'
    )

    assert_nil check.fail_msg
    check.fail!
    assert_not_nil check.fail_msg
  end
end
