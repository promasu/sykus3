define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  'mustache/mustache',
  './localLogin',
  'dojo/text!./templates/CliHostNotReady.html',
  'dojo/i18n!../common/nls/common',
  'dojo/i18n!./nls/common'
], 
function (
  declare, domConstruct, on, query, lang, mustache, localLogin,
  tCliHostNotReady, iCommon, iCli
) {
  return declare(null, {
    constructor: function () {
      var tcCliHostNotReady = mustache.render(tCliHostNotReady, {
        iCommon: iCommon,
        iCli: iCli
      });

      domConstruct.place(tcCliHostNotReady, 'main', 'only');

      on(query('.js-locallogin'), 'click', localLogin);
      on(query('.js-reboot'), 'click', lang.hitch(this, this.reboot));
    },

    reboot: function () {
      window.lightdm.restart();
    },

    destroy: function () { }
  });
});

