define([
  'dojo/_base/declare'
],
function (declare) {
  return declare(null, {
    storeTarget: '/api/printers/drivers/',

    formatObject: function (item) {
      return item.name;
    },

    valueObject: function (item) {
      return item.name;
    },

    objectSort: function (a, b) {
      return a.name === b.name ?  0 : ((a.name > b.name) ? 1 : -1);
    },

    objectFromValue: function (value) {
      return this.store.query({ name: value })[0];
    }
  });
});

