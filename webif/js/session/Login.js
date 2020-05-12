define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/store/JsonRest',
  'dojo/query',
  'dojo/cookie',
  'dojo/hash',
  'dojo/has',
  'dojo/dom-construct',
  'mustache/mustache',
  '../common/apiStore',
  '../common/Form',
  '../config',
  '../bootstrap',
  '../nav',
  './identity',
  'dojo/text!./templates/Login.html',
  'dojo/text!./templates/BrowserError.html',
  'dojo/i18n!../common/nls/common',
  'dojo/i18n!./nls/common',
  'dojo/i18n!./nls/browsererror'
], 
function(
  declare, lang, JsonRest, query, cookie, hash, has, domConstruct,
  mustache, apiStore, Form, config, bootstrap, nav, identity, 
  tLogin, tBrowserError, iCommon, iSession, iBrowserError
) {
  return declare([ Form ], {
    redirect: null,

    constructor: function (args) {
      if(!this.checkBrowser()) {
        return;
      }

      this.redirect = args;
      this.host_login = (this.redirect === 'cli/Auth');

      if (!this.host_login) {
        nav.set('login', 'login', 'x');
      }

      this.template = mustache.render(tLogin, {
        iCommon: iCommon,
        iSession: iSession
      });

      apiStore.clearStores();
      this.store = new JsonRest({ target: '/api/sessions/' });

      this.inherited(arguments);
      this.reset();
    },

    checkBrowser: function () {
      var tcBrowserError, oldBrowser = false;

      if (has('chrome') && has('chrome') < 22) {
        oldBrowser = true;
      }
      if (has('ff') && has('ff') < 15) {
        oldBrowser = true;
      }

      if (!oldBrowser) {
        if (has('webkit') || has('mozilla') || has('chrome')) {
          return true; 
        }
      }

      tcBrowserError = mustache.render(tBrowserError, {
        iBrowserError: iBrowserError
      });

      nav.set('login', 'login', 'x');
      domConstruct.place(tcBrowserError, 'main', 'only');
      return false;
    },

    reset: function () {
      query('.js-hostname').text(config.get('hostname'));

      this.getField('username').value = identity.getUserName() || '';
      this.getField('password').value = '';
      if (identity.getUserName()) {
        this.getField('password').focus();
      }
      else {
        this.getField('username').focus();
      }
    },

    submitCallback: function () {
      var data = {
        username: this.getField('username').value,
        password: this.getField('password').value,
        host_login: this.host_login
      };

      // store password in plaintext for CLI login
      if (this.host_login) {
        identity.storePassword(data.password);
      }

      this.store.put(data).then(
        lang.hitch(this, function (res) {
          if (res.password_expired) {
            identity.setUserName(data.username);
            hash('session/ChangePassword!expired');
            return;
          }

          cookie('session_id', res.id, { path: '/' });

          identity.refresh().then(lang.hitch(this, function () {
            bootstrap.clearAllAlerts();
            hash(this.redirect || 'dashboard'); 
          }));
        }), 
        lang.hitch(this, function () {
          bootstrap.showAlert('alert-danger', iSession.invalidLoginAlert);
          this.reset();
        }));
    },

    destroy: function () { }
  });
});

