define([
  'dojo/_base/declare',
  'dojo/cookie',
  'dojo/hash',
  'dojo/store/JsonRest',
  '../common/apiStore',
  './identity'
], 
function(
  declare, cookie, hash, JsonRest, apiStore, identity
) {
  return declare(null, {
    constructor: function () {
      if (cookie('session_id')) {
        new JsonRest({ target: '/api/sessions/' }).
        remove(cookie('session_id'));
      }

      apiStore.clearStores();
      cookie('session_id', null, { expires: -1 });
      identity.reset();
      hash('session/Login!dashboard');
    },

    destroy: function () { }
  });
});

