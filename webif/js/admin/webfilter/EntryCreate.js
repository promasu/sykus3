define([
  'dojo/_base/declare',
  'dojo/hash',
  'mustache/mustache',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  '../../common/apiStore',
  '../../common/Form',
  '../../session/identity',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/text!./templates/EntryCreate.html'
],
function (
  declare, hash, mustache, bootstrap, nav, xhrerror, apiStore, Form, 
  identity, iWebfilter, iCommon, tEntryCreate
) {
  return declare([ Form ], {
    constructor: function () {
      identity.enforcePermission('webfilter_write');

      nav.set('admin', 'webfilter', 'entries');

      this.template = mustache.render(tEntryCreate, {
        iCommon: iCommon,
        iWebfilter: iWebfilter
      });

      this.inherited(arguments);

      this.store = apiStore('/api/webfilter/entries/');
    },

    validateCallback: function (field) { 
      switch (field) {
        case 'domain': 
          if (!this.getField(field).value.match(/^[a-z0-9\-\.]{3,100}$/)) {
            return iWebfilter.entryInvalidDomain;
          }
          return true;

        default: return true; 
      }
    },

    submitCallback: function (data) {
      data.type = this.getRadio('type');

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          iWebfilter.entryCreatedAlert
        );

        hash('admin/webfilter/EntryList');
      }, xhrerror);
    },

    destroy: function () { }

  });
});

