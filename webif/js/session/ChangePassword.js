define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/store/JsonRest',
  'dojo/hash',
  'mustache/mustache',
  '../common/apiStore',
  '../common/Form',
  '../bootstrap',
  '../nav',
  './identity',
  'dojo/text!./templates/ChangePassword.html',
  'dojo/i18n!../common/nls/common',
  'dojo/i18n!./nls/common'
], 
function(
  declare, lang, JsonRest, hash, mustache, apiStore, Form, bootstrap, nav, 
  identity, tChangePassword, iCommon, iSession
) {
  return declare([ Form ], {
    constructor: function (args) {
      var expired = (args === 'expired');

      if (expired && !window.lightdm) {
        bootstrap.showAlert('alert-danger', iSession.expiredPasswordCliAlert);
        hash('session/Login');
        return;
      }

      if (!identity.getUserName()) {
        hash('session/Login');
        return;
      }

      if (expired) {
        nav.set('login', 'login', 'x');
      }
      else {
        nav.set('user', 'dashboard', 'pwd');
      }

      this.template = mustache.render(tChangePassword, {
        title: expired ? iSession.changePasswordTitleExpired : 
        iSession.changePasswordTitle,
        iCommon: iCommon,
        iSession: iSession
      });

      apiStore.clearStores();
      this.store = new JsonRest({ target: '/api/password/' });

      this.inherited(arguments);
      this.reset();
    },

    reset: function () {
      var password = identity.getPassword();

      this.getField('password-old').value = password || '';
      this.getField('password-new').value = '';
      this.getField('password-repeat').value = '';
      
      this.getField(password ? 'password-new' : 'password-old').focus();
    },

    submitCallback: function () {
      var data = {
        username: identity.getUserName(),
        old_password: this.getField('password-old').value,
        new_password: this.getField('password-new').value
      };

      if (data.new_password.length < 8) {
        bootstrap.showAlert('alert-danger', iSession.passwordTooShortAlert);
        this.reset();
        return;
      } 

      if (data.new_password !== this.getField('password-repeat').value) {
        bootstrap.showAlert('alert-danger', iSession.passwordMismatchAlert);
        this.reset();
        return;
      }

      this.store.put(data).then(function () {
        bootstrap.clearAllAlerts();
        bootstrap.showAlert('alert-success', iSession.passwordChangedAlert);

        hash(window.lightdm ? 'cli/Start' : 'dashboard'); 
      }, 
      lang.hitch(this, function () {
        bootstrap.showAlert('alert-danger', iSession.invalidLoginAlert);
        this.reset();
      }));
    },

    destroy: function () { }
  });
});

