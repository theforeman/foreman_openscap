module ArfReportsHelper
  def report_arf_column(event, style = "")
    style = "label-default" if event == 0
    content_tag(:span, event, :class => 'label ' + style)
  end

  def show_logs
    return if @arf_report.logs.empty?
    form_tag arf_report_path(@arf_report), :id => 'level_filter', :method => :get, :class => "form form-horizontal" do
      content_tag(:span, _("Show log messages:") + ' ') +
      select(nil, 'level', [[_('All messages'), 'info'], [_('Failed and Othered'), 'warning'], [_('Failed only'), 'error']],
             {}, { :class => "col-md-1 form-control", :onchange => "filter_by_level(this);" })
    end
  end

  def arf_report_breadcrumbs
    breadcrumbs(:resource_url => api_compliance_arf_reports_path,
                :switchable => false,
                :items => [
                  { :caption => _('Compliance Reports'),
                    :url => url_for(arf_reports_path) },
                  { :caption => @arf_report.host.to_s }
                ])
  end

  def result_tag(level)
    tag = case level
          when 'pass'
            "success"
          when 'fail'
            "danger"
          else
            "warning"
          end
    "class='label label-#{tag} result-filter-tag'".html_safe
  end

  def severity_tag(level)
    tag = case level.downcase.to_sym
          when :low
            "info"
          when :medium
            "warning"
          when :high
            "danger"
          else
            "default"
          end
    "class='label label-#{tag}'".html_safe
  end

  def multiple_actions_arf_report
    actions = [
      [_('Delete reports'), delete_multiple_arf_reports_path]
    ]
  end

  def multiple_actions_arf_report_select
    select_action_button(_("Select Action"), { :id => 'submit_multiple' },
                         multiple_actions_arf_report.map do |action|
                           link_to_function(action[0], "buildArfModal(this, '#{action[1]}')",
                                            :'data-dialog-title' => _("%s - The following compliance reports are about to be changed") % action[0])
                         end.flatten)
  end

  def openscap_proxy_link(arf_report)
    return _("No proxy found!") unless arf_report.openscap_proxy
    display_link_if_authorized(arf_report.openscap_proxy.name, hash_for_smart_proxy_path(:id => arf_report.openscap_proxy_id))
  end

  def reported_info(arf_report)
    msg = _("Reported at %s") % date_time_absolute(arf_report.reported_at)
    msg << _(" for policy %s") % display_link_if_authorized(arf_report.policy.name, hash_for_edit_policy_path(:id => arf_report.policy.id)) if arf_report.policy
    return msg.html_safe unless arf_report.openscap_proxy
    msg += _(" through %s") % openscap_proxy_link(arf_report)
    msg.html_safe
  end

  def host_search_by_rule_result_buttons(source)
    action_buttons(display_link_if_authorized(_('Hosts failing this rule'), hash_for_hosts_path(:search => "fails_xccdf_rule = #{source}")),
                   display_link_if_authorized(_('Hosts passing this rule'), hash_for_hosts_path(:search => "passes_xccdf_rule = #{source}")),
                   display_link_if_authorized(_('Hosts othering this rule'), hash_for_hosts_path(:search => "others_xccdf_rule = #{source}")))
  end
end
