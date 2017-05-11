module PoliciesHelper
  def profiles_selection
    return @scap_content.scap_content_profiles if @scap_content.present?
    return @policy.scap_content.scap_content_profiles if @policy.scap_content.present?
    return []
  end

  def policy_profile_from_scap_content(policy)
    policy.scap_content_profile.nil? ? "Default" : policy.scap_content_profile.title
  end

  def effective_policy_profile(policy)
    policy.tailoring_file ? policy.tailoring_file_profile.title : policy_profile_from_scap_content(policy)
  end

  def scap_content_selector(form)
    scap_contents = ::ForemanOpenscap::ScapContent.authorized(:view_scap_contents).all
    if scap_contents.length > 1
      select_f form, :scap_content_id, scap_contents, :id, :title,
               {:include_blank => _("Choose existing SCAP Content")},
               {:label => _("SCAP Content"),
                :onchange => 'scap_content_selected(this);',
                :'data-url' => method_path('scap_content_selected')}
    else
      select_f form, :scap_content_id, scap_contents, :id, :title,
               {:label => _("SCAP Content"),
                :onchange => 'scap_content_selected(this);',
                :'data-url' => method_path('scap_content_selected')}
    end
  end

  def scap_content_profile_selector(form)
    if profiles_selection.length == 1
      select_f form, :scap_content_profile_id, profiles_selection, :id, :title,
               {:selected => @policy.scap_content_profile_id },
               {:label => _("XCCDF Profile"),
                :disabled => profiles_selection.empty? ? true : false,
                :help_inline => :indicator}
    else
      select_f form, :scap_content_profile_id, profiles_selection, :id, :title,
               {:selected => @policy.scap_content_profile_id,
                :include_blank => _("Default XCCDF profile")},
               {:label => _("XCCDF Profile"),
                :disabled => profiles_selection.empty? ? true : false,
                :help_inline => :indicator}
    end
  end

  def tailoring_file_selector(form)
    select_f form, :tailoring_file_id, ForemanOpenscap::TailoringFile.all.authorized(:view_tailoring_files), :id, :name,
             { :include_blank => _('Choose Tailoring File') },
             { :label => _('Tailoring File'),
               :onchange => 'tailoring_file_selected(this)',
               :'data-url' => method_path('tailoring_file_selected') }
  end

  def tailoring_file_profile_selector(form, tailoring_file)
    if tailoring_file
      select_f form, :tailoring_file_profile_id, tailoring_file.scap_content_profiles, :id, :title,
               { :selected => tailoring_file.scap_content_profiles.first.id },
               { :label => _("XCCDF Profile in Tailoring File"),
                 :help_inline => _("This profile will be used to override the one from scap content") }
    else
      # to make sure tailoring profile id is nil when tailoring file is deselected
      form.hidden_field(:tailoring_file_profile_id, :value => nil)
    end
  end

  def submit_or_cancel_policy(form, overwrite = nil, args = { })
    args[:cancel_path] ||= send("#{controller_name}_path")
    content_tag(:div, :class => "clearfix") do
      content_tag(:div, :class => "form-actions") do
        text    = overwrite ? overwrite : _("Submit")
        options = {:class => "btn btn-primary"}
        options[:'data-id'] = form_to_submit_id(form) unless options.key?(:'data-id')
        previous = form.object.first_step? ? ' ' : previous_link(form)
        cancel_and_submit = content_tag(:div, :class => "pull-right") do
          link_to(_("Cancel"), args[:cancel_path], :class => "btn btn-default") + ' ' +
              form.submit(text, options)
        end
        (previous + cancel_and_submit).html_safe
      end
    end
  end

  def show_partial_wizard(step)
    @policy.current_step == step ? 'show-pane' : 'hide-pane'
  end

  def previous_link(form)
    previous = content_tag(:span, :class => 'glyphicon glyphicon-chevron-left') {}
    content_tag(:div, :class => 'pull-left') do
      link_to(previous.html_safe, '#', :class => 'btn btn-default', :onclick => "previous_step('#{@policy.previous_step}')")
    end
  end

  def days_of_week_hash
    Hash[*Date::DAYNAMES.map { |day| [day.downcase, day] }.flatten]
  end
end
