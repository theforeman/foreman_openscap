$(document).on('ContentLoad', () => {
  if (/^\/compliance\/policies\/\d+\/dashboard$/.test(window.location.pathname)) {
    tfm.dashboard.startGridster();
  }
});
