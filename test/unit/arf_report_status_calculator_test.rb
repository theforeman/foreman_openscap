require 'test_helper'

class ArfReportStatusCalculatorTest < ActiveSupport::TestCase
  test 'it should save metrics as bits' do
    calc = ForemanOpenscap::ArfReportStatusCalculator.new(:counters => { 'passed' => 25, 'othered' => 1024, 'failed' => 10 })
    assert_equal 25, calc.status['passed']
    assert_equal ForemanOpenscap::ArfReport::MAX, calc.status['othered']
    assert_equal 10, calc.status['failed']
  end
end
