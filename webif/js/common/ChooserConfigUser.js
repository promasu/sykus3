define([
  'dojo/_base/declare',
  './apiStore'
],
function (declare, apiStore) {
  return declare(null, {
    storeTarget: '/api/users/',

    constructor: function () {
      this.userClassStore = apiStore('/api/userclasses/');
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
    },

    objectSort: function (a, b) {
      return a.username === b.username ? 
      0 : ((a.username > b.username) ? 1 : -1);
    },

    objectFromValue: function (value) {
      return this.store.query({ username: value })[0];
    }
  });
});

