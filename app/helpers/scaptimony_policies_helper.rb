module ScaptimonyPoliciesHelper
  def profiles_selection
    return @scap_content.scap_content_profiles unless @scap_content.blank?
    return @policy.scap_content.scap_content_profiles unless @policy.scap_content.blank?
    return []
  end

  def submit_or_cancel_policy(form, overwrite = nil, args = { })
    args[:cancel_path] ||= send("#{controller_name}_path")
    content_tag(:div, :class => "clearfix") do
      content_tag(:div, :class => "form-actions") do
        text    = overwrite ? overwrite : _("Submit")
        options = {:class => "btn btn-primary"}
        options.merge! :'data-id' => form_to_submit_id(form) unless options.has_key?(:'data-id')
        previous = form.object.first_step? ? ' ' : previous_link(form)
        link_to(_("Cancel"), args[:cancel_path], :class => "btn btn-default") + previous +
            form.submit(text, options)
      end
    end
  end

  def show_partial_wizard(step)
    @policy.current_step == step ? 'show-pane' : 'hide-pane'
  end

  def previous_link(form)
    (' ' + form.submit(_('Previous'), :class => 'btn btn-default', :onclick => "previous_step('#{@policy.previous_step}')") + ' ').html_safe
  end
end
