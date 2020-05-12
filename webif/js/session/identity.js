define([
  'dojo/request',
  'dojo/hash',
  'dojo/cookie',
  'dojo/_base/lang',
  '../bootstrap',
  '../xhrerror',
  'dojo/i18n!./nls/common'
], 
function (
  request, hash, cookie, lang, bootstrap, xhrerror, iSession
) {
  var userData = null, permissionList = {}, password = null, userName = null;

  var methods = {
    enforcePermission: function (permission) {
      if (permissionList[permission]) {
        return;
      }
      hash('#dashboard');
      bootstrap.showAlert('alert-danger', iSession.alertPermission);
    },

    permission: function (permission) {
      return !!permissionList[permission];
    },

    permissions: function () {
      return lang.clone(permissionList);
    },

    storePassword: function (p) {
      password = p;
    },

    // return password only once for safety reasons
    getPassword: function () {
      var p = password;
      password = null;
      return p;
    },

    getUser: function() {
      return userData;
    },

    setUserName: function (u) {
      userName = u;
    },

    getUserName: function () {
      return userData ? userData.username : userName;
    },

    reset: function () {
      userData = null;
      userName = null;
      permissionList = {};
    },

    keepalive: function () {
      var url;
      if (userData) {
        url = '/api/sessions/' + cookie('session_id') + '/keepalive';
        request.get(url).then(function () {}, methods.refresh);
      }
    },

    refresh: function () {
      var idreq = request.get('/api/identity', { handleAs: 'json' });

      return idreq.then(function (res) {
        var i, list = res.permissions;

        userData = res.user;
        permissionList = {};

        for (i = 0; i < list.length; i += 1) {
          permissionList[list[i]] = true;
        }
      }, xhrerror);
    }
  };

  return methods;
});

