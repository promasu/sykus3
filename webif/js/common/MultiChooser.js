define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/_base/array',
  'dojo/query',
  'dojo/on',
  'dojo/dom-construct',
  './Chooser',
  'dojo/i18n!./nls/common'
],
function (
  declare, lang, array, query, on, domConstruct, Chooser, iCommon
) {
  return declare([ Chooser ], {
    selectOnTab: false,
    selectOnBlur: false,

    constructor: function (_d1, _d2, listNode) {
      this.memberList = {};
      this.listNode = listNode;
      this.updateMemberList();
    },

    choose: function(value) {
      var item = this.objectFromValue(value || this.getFirst());

      if (item) {
        this.memberList[item.id] = item;
      }
      this.updateMemberList();
    },

    filterFunc: function (item) {
      if (this.memberList[item.id]) {
        return false;
      }
      return this.inherited(arguments);
    },

    remove: function (id, e) {
      delete this.memberList[id];
      this.updateMemberList();
      e.preventDefault();
    },

    getMemberIdArray: function () {
      var id, arr = [];
      for (id in this.memberList) {
        if (this.memberList.hasOwnProperty(id)) {
          arr.push(id);
        }
      }
      return arr;
    },

    setData: function (data) {
      this.memberList = {};
      array.forEach(data, lang.hitch(this, function (item) {
        this.memberList[item.id] = item;
      }));
      this.updateMemberList();
    },

    updateMemberList: function () {
      var id, arr = [];

      query('*', this.listNode).forEach(domConstruct.destroy);

      for (id in this.memberList) {
        if (this.memberList.hasOwnProperty(id)) {
          arr.push(this.memberList[id]);
        }
      }

      arr.sort(this.objectSort);
      array.forEach(arr, lang.hitch(this, function (item) {
        var node, deleteNode;

        node = domConstruct.create('span', {
          className: 'label label-primary label-multichooser',
          innerHTML: this.formatObject(item)
        }, this.listNode, 'last');

        deleteNode = domConstruct.create('a', {
          href: '#',
          className: 'label label-default',
          innerHTML: '&times;'
        }, node, 'first');

        on(deleteNode, 'click', 
          lang.hitch(this, lang.partial(this.remove, item.id)));
      }));

      if (arr.length === 0) {
        domConstruct.create('span', {
          className: 'label label-inverse',
          innerHTML: iCommon.chooserNoMembers
        }, this.listNode, 'last');
      }

    }

  });
});

