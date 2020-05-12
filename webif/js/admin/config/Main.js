define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/_base/array',
  'dojo/request',
  'mustache/mustache',
  '../../common/Form',
  '../../bootstrap',
  '../../config',
  '../../nav',
  '../../xhrerror',
  '../../session/identity',
  'dojo/text!./templates/Main.html',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!./nls/common'
], 
function(
  declare, lang, array, request, mustache, Form, bootstrap, config, nav, 
  xhrerror, identity, tMain, iCommon, iConfig
) {
  return declare([ Form ], {
    fields: [ 
      'school_name', 'wlan_ssid', 'wlan_key', 'smartboard_serial',
      'radius_secret'
    ],

    constructor: function () {
      identity.enforcePermission('config_edit');

      nav.set('admin', 'config', 'main');

      this.template = mustache.render(tMain, {
        iCommon: iCommon,
        iConfig: iConfig
      });

      this.inherited(arguments);
      this.load();
    },

    load: function () {
      request.get('/api/config/', { 
        handleAs: 'json' 
      }).then(lang.hitch(this, function (data) {
        array.forEach(this.fields, lang.hitch(this, function (e) {
          this.getField(e).value = data[e] || '';
        }));
      }));
    },

    submitCallback: function () {
      var data = {};

      array.forEach(this.fields, lang.hitch(this, function (e) {
        data[e] = this.getField(e).value;
      }));

      request.post('/api/config/', {
        data: JSON.stringify(data)
      }).then(function () {
        config.refresh();
        bootstrap.showAlert('alert-success', iConfig.savedAlert);
      }, xhrerror); 
    },

    destroy: function () { }
  });
});

