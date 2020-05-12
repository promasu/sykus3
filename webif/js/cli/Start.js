define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/hash',
  'dojo/cookie',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  'mustache/mustache',
  '../config',
  '../nav',
  '../bootstrap',
  './localLogin',
  'dojo/text!./templates/CliStart.html',
  'dojo/text!../common/templates/partialPopover.html',
  'dojo/i18n!../common/nls/common',
  'dojo/i18n!./nls/common'
], 
function (
  declare, domConstruct, hash, cookie, on, query, lang, mustache,
  config, nav, bootstrap, localLogin, tCliStart, tPartialPopover, iCommon, iCli
) {
  return declare(null, {
    shutdownTimeout: 20 * (60 * 1000), // 20 min

    constructor: function () {
      nav.set('cli', 'login', 'x');

      // reset session state
      cookie('session_id', null, { expires: -1 });

      var tcCliStart = mustache.render(tCliStart, {
        iCommon: iCommon,
        iCli: iCli
      });

      domConstruct.place(tcCliStart, 'main', 'only');

      on(query('.js-reboot'), 'click', lang.hitch(this, this.reboot));
      on(query('.js-poweroff'), 'click', lang.hitch(this, this.poweroff));
      on(query('.js-locallogin'), 'click', lang.hitch(this, this.locallogin));

      setTimeout(function () {
        window.lightdm.shutdown();
      }, this.shutdownTimeout);

      if (config.get('allow_local_login')) {
        query('.js-locallogin').removeClass('hide');
      }

      if (config.get('host_ready')) {
        hash('session/Login!cli/Auth');
      }
      else {
        hash('cli/HostNotReady');
      }
    },

    locallogin: function (e) {
      var ref, template, node;

e.stopPropagation();

      ref = query('.js-locallogin')[0];

template = mustache.render(tPartialPopover, {}, {
        popoverTitle: iCli.localloginTitle,
        popoverText: iCli.localloginText,
        popoverButton: iCli.localloginTitle
      });
      node = bootstrap.showPopover(template, ref, 'bottom');
      on(query('.js-btn-confirm', node), 'click', function () {
        localLogin();
      });
    },

    reboot: function (e) {
      var ref, template, node;

      e.stopPropagation();

      ref = query('.js-reboot')[0];
      template = mustache.render(tPartialPopover, {}, {
        popoverTitle: iCli.rebootTitle,
        popoverText: iCli.rebootText,
        popoverButton: iCli.rebootTitle
      });
      node = bootstrap.showPopover(template, ref, 'bottom');
      on(query('.js-btn-confirm', node), 'click', function () {
        window.lightdm.restart();
      });
    },

    poweroff: function (e) {
      var ref,template, node;

      e.stopPropagation();

      ref = query('.js-poweroff')[0];
      template = mustache.render(tPartialPopover, {}, {
        popoverTitle: iCli.poweroffTitle,
        popoverText: iCli.poweroffText,
        popoverButton: iCli.poweroffTitle
      });
      node = bootstrap.showPopover(template, ref, 'bottom');
      on(query('.js-btn-confirm', node), 'click', function () {
        window.lightdm.shutdown();
      });

    },

    destroy: function () { }
  });
});

