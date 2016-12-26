module ComplianceDashboardHelper

  def latest_compliance_headers
    string =  "<th class='col-md-7'>#{_("Host")}</th>"
    string += "<th class='col-md-3'>#{_("Policy")}</th>"
    # TRANSLATORS: initial character of Passed
    string += translated_header(s_('Passed|P'), _('Passed'))
    # TRANSLATORS: initial character of Failed
    string += translated_header(s_('Failed|F'), _('Failed'))
    # TRANSLATORS: initial character of Othered which is an SCAP term
    string += translated_header(s_('Othered|O'), _('Othered'))

    string.html_safe
  end

end
