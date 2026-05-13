require 'test_plugin_helper'

class BookmarkControllerValidatorExtensionsTest < ActiveSupport::TestCase
  # All controllers including AutoCompleteSearch, except ComplianceDashboardController which is broken anyway
  [ArfReportsController, ScapContentsController,
   PoliciesController, TailoringFilesController].each do |controller_class|
    test "#{controller_class.controller_name} should be a valid bookmark controller" do
      controller = controller_class.controller_name
      bookmark = FactoryBot.build_stubbed(:bookmark, :name => "#{controller} bookmark",
                                                     :controller => controller,
                                                     :query => 'search query',
                                                     :public => true)
      assert bookmark.valid?, "#{controller} should be a valid bookmark controller, errors: #{bookmark.errors.full_messages}"
    end
  end
end
