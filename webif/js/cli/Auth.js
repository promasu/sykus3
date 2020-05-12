define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/hash',
  'dojo/cookie',
  '../bootstrap',
  '../session/identity',
  'dojo/i18n!./nls/common'
], 
function (
  declare, domConstruct, hash, cookie, bootstrap, identity, iCli
) {
  return declare(null, {
    constructor: function () {
      var data = {
        user: identity.getUser(),
        password: identity.getPassword(),
        session_id: cookie('session_id')
      };

      domConstruct.place('<div></div>', 'main', 'only');

      try {
        window.lightdm.cancel_authentication();

        window.show_prompt = function () {
          window.lightdm.provide_secret(JSON.stringify(data)); 
        };

        window.authentication_complete = function () {
          if (window.lightdm.is_authenticated) {
            window.lightdm.login(data.user.username, 
            window.lightdm.default_session);
          }
          else {
            hash('cli/Start');
          }
        };

        window.lightdm.start_authentication(data.user.username);
      }
      catch (e) {}

      // in case any errors happen
      setTimeout(function () {
        bootstrap.showAlert('alert-danger', iCli.loginError);
        hash('cli/Start');
      }, 25000);
    },

    destroy: function () { }
  });

});

