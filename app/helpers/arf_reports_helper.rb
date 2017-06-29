module ArfReportsHelper
  def report_arf_column(event, style = "")
    style = "label-default" if event == 0
    content_tag(:span, event, :class=>'label ' + style)
  end

  def show_logs
    return if @arf_report.logs.empty?
    form_tag arf_report_path(@arf_report), :id => 'level_filter', :method => :get, :class => "form form-horizontal" do
      content_tag(:span, _("Show log messages:") + ' ') +
      select(nil, 'level', [[_('All messages'), 'info'],[_('Failed and Othered'), 'warning'],[_('Failed only'), 'error']],
             {}, {:class=>"col-md-1 form-control", :onchange =>"filter_by_level(this);"})
    end
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
    select_action_button(_("Select Action"), {:id => 'submit_multiple'},
      multiple_actions_arf_report.map do |action|
        link_to_function(action[0], "buildArfModal(this, '#{action[1]}')",
         :'data-dialog-title' => _("%s - The following compliance reports are about to be changed") % action[0])
      end.flatten)
  end
end
