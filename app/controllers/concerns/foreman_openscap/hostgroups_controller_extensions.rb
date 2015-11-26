module ForemanOpenscap
  module HostgroupsControllerExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :load_vars_for_ajax, :openscap
      alias_method_chain :inherit_parent_attributes, :openscap
    end

    def load_vars_for_ajax_with_openscap
      load_vars_for_ajax_without_openscap
      @openscap_proxy = @hostgroup.openscap_proxy
    end

    def inherit_parent_attributes_with_openscap
      inherit_parent_attributes_without_openscap
      @hostgroup.openscap_proxy ||= @parent.openscap_proxy
    end
  end
end
