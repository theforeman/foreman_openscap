function updateOpenscapProxy(element){
  var id = $("form").data('id')
  var url = $(element).attr('data-url');
  var data = $("form").serialize().replace('method=put', 'method=post');
  if (url.match('hostgroups')) {
    data = data + '&hostgroup_id=' + id
  } else {
    data = data + '&host_id=' + id
  }

  toggleErrorText("");
  $(element).indicator_show();
  $.ajax({
    type: 'post',
    url:  url,
    data: data,
    error: function(response) {
      var text = $(response.responseText).find('.form-group.has-error').find('.help-block.help-inline').text();
      addOpenscapProxyError(text);
      $(element).indicator_hide();
    },
    success: function(response) {
      removeOpenscapProxyError();
      $('#puppetclasses_parameters').replaceWith($(response).find("#puppetclasses_parameters"));
      $(element).indicator_hide();
    }
  })
}

function findOpenscapProxyFormGroup(){
  return $('form').find("label[for='openscap_proxy_id']").parents(".form-group").first();
}

function addOpenscapProxyError(text){
  var formGroup = findOpenscapProxyFormGroup();
  $(formGroup).addClass("has-error");
  toggleErrorText(text);
}

function removeOpenscapProxyError(){
  var formGroup = findOpenscapProxyFormGroup();
  $(formGroup).removeClass("has-error");
  toggleErrorText("");
}

function toggleErrorText(text){
  if(text){
    $(findOpenscapProxyFormGroup()).find(".help-block.help-inline").append('<span id="openscap_error">' + text + '</span>');
  } else {
    $(findOpenscapProxyFormGroup()).find("#openscap_error").remove();
  }
}
