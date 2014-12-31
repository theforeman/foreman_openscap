module ScaptimonyPoliciesHelper
  def profiles_selection
    return @scap_content.scap_content_profiles unless @scap_content.blank?
    return @policy.scap_content.scap_content_profiles unless @policy.scap_content.blank?
    return []
  end

  def submit_or_cancel_policy(f, overwrite = nil, args = { })
    args[:cancel_path] ||= send("#{controller_name}_path")
    content_tag(:div, :class => "clearfix") do
      content_tag(:div, :class => "form-actions") do
        text    = overwrite ? overwrite : _("Submit")
        options = {:class => "btn btn-primary"}
        options.merge! :'data-id' => form_to_submit_id(f) unless options.has_key?(:'data-id')
        previous = f.object.first_step? ? ' ' : previous_link(f.object)
        link_to(_("Cancel"), args[:cancel_path], :class => "btn btn-default") + previous +
            f.submit(text, options)
      end
    end
  end

  def previous_link(policy)
    (' ' + link_to(_('Previous'), edit_scaptimony_policy_path(policy, :current_step => policy.previous_step), :class => "btn btn-default") + ' ').html_safe
  end
end
