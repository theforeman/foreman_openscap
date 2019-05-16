$(document).on('ContentLoad', function(){
  if (/^\/compliance\/policies\/\d+\/dashboard$/.test(window.location.pathname)) {
    tfm.dashboard.startGridster();
  }
});
