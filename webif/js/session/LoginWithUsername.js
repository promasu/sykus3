define([
  'dojo/_base/declare',
  './identity',
  'dojo/hash'
], 
function(
  declare, identity, hash
) {
  return declare(null, {
    constructor: function (args) {
      identity.setUserName(args);
      hash('session/Login!dashboard');
    },

    destroy: function () { }
  });

});

