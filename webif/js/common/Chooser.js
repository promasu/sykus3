define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/keys',
  'dojo/query',
  'dojo/on',
  'dojo/dom-class',
  'dojo/dom-construct',
  './apiStore',
  'dojo/i18n!./nls/common'
], 
function (
  declare, lang, keys, query, on, domClass, domConstruct, apiStore, iCommon
) {

  return declare(null, {
    maxItems: 30,
    linkSelected: null,
    selectOnTab: true,
    selectOnBlur: true,

    constructor: function (inputNode, dropdownNode) {
      this.inputNode = inputNode;
      this.dropdownNode = dropdownNode;
      this.store = apiStore(this.storeTarget);

      on(inputNode, 'keydown', lang.hitch(this, this.keydown));
      on(inputNode, 'keyup', lang.hitch(this, this.update));
      on(inputNode, 'blur', lang.hitch(this, this.blur));
      on(inputNode, 'focus', lang.hitch(this, this.update));

      domClass.add(this.dropdownNode, 'dropdown-block hide');
    },

    blur: function () {
      // give link click handler time to do its magic
      setTimeout(lang.hitch(this, function () {
        if (domClass.contains(this.dropdownNode, 'hide')) {
          return;
        }

        if (this.selectOnBlur) {
          this.choose();
        } else {
          this.hide();
        }
      }), 200);
    },

    getFirst: function() {
      if (this.results && this.results.length > 0) {
        return this.valueObject(this.results[0]);
      }
      return '';
    },

    choose: function (value) {
      value = value || this.getFirst();
      this.inputNode.value = value;

      this.hide();

      // used for validation mechanism
      on.emit(this.inputNode, 'change', {
        bubbles: true,
        cancelable: true
      });
    },

    show: function () {
      domClass.remove(this.dropdownNode, 'hide');
    },

    hide: function () {
      domClass.add(this.dropdownNode, 'hide');
    },

    keydown: function (e) {
      if (e.keyCode === keys.TAB) {
        if (this.selectOnTab) {
          this.choose();
        }
        else {
          this.hide();
        }
      }

      if (e.keyCode === keys.ENTER) {
        this.choose();
        e.preventDefault();
      }
    },

    filterFunc: function (item) {
      var i, haystack = this.formatObject(item).toLowerCase(), needleArr;

      needleArr = this.inputNode.value.toLowerCase().split(' ');

      for (i = 0; i < needleArr.length; i += 1) {
        if (haystack.indexOf(needleArr[i]) < 0) {
          return false;
        }
      }
      return true;
    },

    highlight: function (string, data) {
      var i, needleArr = string.split(' '), re, needleArrNew = [];

      for (i = 0; i < needleArr.length; i += 1) {
        needleArrNew.push(needleArr[i].replace(/[^a-z0-9]/ig, ''));
      }

      re = new RegExp('(' + needleArrNew.join('|') + ')', 'ig');
      return data.replace(re, '<strong>$1</strong>');
    },

    update: function () {
      if (this.inputNode.value === '')  {
        this.hide();
        return;
      }
      this.show();

      this.results = this.store.query(lang.hitch(this, this.filterFunc));

      query('li', this.dropdownNode).forEach(domConstruct.destroy);

      if (this.results.length > this.maxItems || this.results.length === 0) {
        domConstruct.create('div', { 
          innerHTML: (this.results.length ? 
          iCommon.chooserTooMany : iCommon.chooserNone)
        }, domConstruct.create('li', {}, this.dropdownNode), 'only');    

        // avoid selecting first entry on blur
        this.results = [];
        return;
      }

      this.results.forEach(lang.hitch(this, function (item) {
        var a, li, content;

        li = domConstruct.create('li', {}, this.dropdownNode, 'last');

        content = this.formatObject(item);
        content = this.highlight(this.inputNode.value, content);

        a = domConstruct.create('a', { 
          href: '#', 
          innerHTML: content 
        }, li, 'last');

        (function (that, value) {
          on(a, 'click', function (e) {
            that.choose(value);
            e.preventDefault();
          });
        })(this, this.valueObject(item));
      }));
    }
  });
});

