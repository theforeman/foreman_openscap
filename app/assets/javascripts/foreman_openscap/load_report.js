$(document).ready(function() {
    $('#frame').on("load",function() {
        $('#loading').hide();
        $('#frame').show().css('min-height', '800px');
    });
});
