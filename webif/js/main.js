define([
  'dojo/_base/window',
  'dojo/router',
  'dojo/hash',
  'dojo/on',
  'dojo/query',
  'mustache/mustache',
  './bootstrap',
  './config',
  './session/identity',
  'dojo/text!./layout/templates/main.html',
  'dojo/i18n!./common/nls/nav',

  './routes',
  'dojo/NodeList-dom',
  'dojo/NodeList-traverse',
  'dojo/NodeList-manipulate',
  'dojo/domReady!'
], 
function ( 
  win, router, hash, on, query, mustache, bootstrap, config,
  identity, tMain, iNav
) {
  if (window.top.location !== window.location) {
    window.top.location.href = window.location.href;
    return;
  }

  if (window.lightdm) {
    query('body').addClass('cli');
  }

  win.body().innerHTML = mustache.render(tMain, {
    iNav: iNav
  });

  setInterval(config.refresh, 10000);

  on(win.body(), 'keyup', function (e) {
    if (e.keyCode === 27) {
      bootstrap.clearPopover();
    }
  });

  config.refresh().then(function() {
    identity.refresh().then(function () {
      setInterval(identity.keepalive, 4000);
      identity.keepalive();

      if (window.lightdm) {
        hash('cli/Start');
      }
      else if (hash() === '' || hash() === 'session/Login!') {
        hash('session/Login!dashboard');
      }

      query('title')[0].innerHTML += (' - ' + config.get('school_name'));

      router.startup();
    });
  });
});

