function scap_content_selected(element){
  var attrs = attribute_hash(['scap_content_id']);
  var url = $(element).attr('data-url');
  $(element).indicator_show();
  $.ajax({
    data: attrs,
    type: 'post',
    url: url,
    complete: function() { $(element).indicator_hide();},
    success: function(request) {
      $('#scap_content_profile_select').html(request);
    }
  })
}
