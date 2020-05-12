define([
  'dojo/_base/declare',
  './apiStore',
  './Chooser'
],
function (declare, apiStore, Chooser) {
  return declare([ Chooser ], {
    storeTarget: '/api/users/',

    constructor: function () {
      this.userClassStore = apiStore('/api/userclasses/');
      this.inherited(arguments);
    },

    formatObject: function (item) {
      var uc = '';

      if (item.user_class) {
        uc = this.userClassStore.get(item.user_class).name + ', ';
      }
      return item.first_name + ' ' + item.last_name + 
        ' (' + uc + item.username + ')';
    },

    valueObject: function (item) {
      return item.username;
    }
  });
});
