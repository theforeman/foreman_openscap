function scap_content_selected(element){
  var attrs = attribute_hash(['scap_content_id']);
  var url = $(element).attr('data-url');
  tfm.tools.showSpinner();
  $.ajax({
    data: attrs,
    type: 'post',
    url: url,
    complete: function() { reloadOnAjaxComplete($(element));},
    success: function(request) {
      $('#scap_content_profile_select').html(request);
    }
  })
}

function tailoring_file_selected(element) {
  var attrs = attribute_hash(['tailoring_file_id']);
  var url = $(element).attr('data-url');
  tfm.tools.showSpinner();
  $.ajax({
    data: attrs,
    type: 'post',
    url: url,
    complete: function() { reloadOnAjaxComplete($(element));},
    success: function(request) {
      $('#tailoring_file_profile_select').html(request);
    }
  })
}

function previous_step(previous) {
  $('#policy_current_step').val(previous);
  $('#new_policy').trigger("submit");
}

function period_selected(period) {
  $("#policy_weekday, #policy_day_of_month, #policy_cron_line").closest("div.clearfix").hide();
  switch($(period).val()) {
    case 'weekly':
      field = "#policy_weekday";
      break;
    case 'monthly':
      field = "#policy_day_of_month";
      break;
    case 'custom':
      field = "#policy_cron_line";
      break;
    default:
      field = "";
  }
  $(field).closest("div.clearfix").show();
}
