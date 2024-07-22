function showReportDetails(log_id, event) {
  var showDetails = $('#details-' + log_id)
  showDetails.toggle();
  showDetails.is(':visible') ? $(event).find('span').attr('class', 'glyphicon glyphicon-collapse-up') : $(event).find('span').attr('class', 'glyphicon glyphicon-collapse-down');
}

function showRemediationWizard(log_id) {
  var wizard_button = $('#openscapRemediationWizardButton');
  wizard_button.attr('data-log-id', log_id);
  wizard_button.trigger("click");
}
