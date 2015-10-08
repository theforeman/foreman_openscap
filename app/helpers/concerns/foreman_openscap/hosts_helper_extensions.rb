module ForemanOpenscap
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :multiple_actions, :scap
      alias_method_chain :name_column, :scap
    end

    def multiple_actions_with_scap
      multiple_actions_without_scap << [_('Assign Compliance Policy'), select_multiple_hosts_scaptimony_policies_path]
    end

    def name_column_with_scap(record)
      return _('Host is deleted') if record.nil?
      return content_tag(:span, s_("Unlinked|U"), {:rel => "twipsy", :class => "label label-light label-warning", :"data-original-title" => _('Unlinked')}) +
          link_to(" #{record.name}", "/content_hosts/#{record.uuid}/info") if defined?(::Katello::System) && record.is_a?(::Katello::System)
      return name_column_without_scap(record)
    end
  end
end
