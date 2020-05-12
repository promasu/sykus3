define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/request',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  '../../common/Grid',
  'mustache/mustache',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  '../../session/identity',
  'dojo/text!./templates/EntryList.html',
  'dojo/text!./templates/EntryListEntry.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/text!../../common/templates/partialPopover.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, domConstruct, request, on, query, lang, Grid, mustache, bootstrap, 
  nav, xhrerror, identity, tEntryList, tEntryListEntry, tGridFilter, 
  tPartialPopover, iWebfilter, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/webfilter/entries/',
    domTable: 'EntryListTable',
    tRow: tEntryListEntry,

    constructor: function () {
      nav.set('admin', 'webfilter', 'entries');
      identity.enforcePermission('webfilter_read');

      var tcEntryList = mustache.render(tEntryList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iWebfilter: iWebfilter
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcEntryList, 'main', 'only');

      if (identity.permission('webfilter_write')) {
        query('.js-btn-create').removeClass('hide');
      }

      this.inherited(arguments);
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, ref, node;

      if (!identity.permission('webfilter_write')) {
        return;
      }

      template = mustache.render(tPartialPopover, {
        data: this.store.get(rowId), 
        popoverButtonClass: 'btn-danger'
      }, {
        popoverTitle: iWebfilter.entryDeleteTitle,
        popoverText: iWebfilter.entryDeleteText,
        popoverButton: iWebfilter.entryDeleteButton
      });

      ref = query(':first-child', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.btn', node), 
        'click', 
        lang.hitch(this, lang.partial(this.deleteEntry, rowId))
      );
    },

    deleteEntry: function (id) {
      this.store.remove(id).then(function () {
        bootstrap.showAlert('alert-success', iWebfilter.entryDeletedAlert);
      }, xhrerror);
    },

    dataValueCallback: function (field, value) {
      switch (field) {
        case 'type':
          switch (value) {
            case 'black_all': return iWebfilter.entryTypeBlackAll;
            case 'nonstudents_only': 
              return iWebfilter.entryTypeNonStudentsOnly;
            case 'white_all': return iWebfilter.entryTypeWhiteAll;
          }
          throw false;

        default: return value;
      }
    },

    dataTitleCallback: function (field, value) {
      switch (field) {

        case 'type':
          switch (value) {
            case 'black_all': return iWebfilter.entryTypeBlackAllTitle;
            case 'nonstudents_only': 
              return iWebfilter.entryTypeNonStudentsOnlyTitle;
            case 'white_all': return iWebfilter.entryTypeWhiteAllTitle;
          }
          throw false;

        default: return '';
      }
    },

    dataClassCallback: function (field, value) {
      switch (field) {
        case 'type':
          switch (value) {
            case 'black_all': return 'label-danger';
            case 'nonstudents_only': return 'label-info'; 
            case 'white_all': return 'label-success';
          }
          throw false;

        default: return '';
      }
    },

    selectEntry: function (id, selected) {
      var data = {
        id: id,
        selected: selected
      };

      this.store.put(data).then(lang.hitch(this, function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iWebfilter.entrySelectedAlert, this.store.get(id))
        );
      }, xhrerror));
    },

    searchPopover: function () {
      var template, node, ref;

      ref = query('.js-btn-search')[0];
      template = mustache.render('', {
        iWebfilter: iWebfilter,
        iCommon: iCommon
      });

      node = bootstrap.showPopover(template, ref, 'left');
      query('.js-input-domain', node)[0].focus();

      on(
        query('.js-search-form', node),
        'submit', 
        lang.hitch(this, this.search)
      );
    },

    search: function (e) {
      e.preventDefault();

      request.post('/api/webfilter/search/', {
        data: JSON.stringify({ domain: query('.js-input-domain')[0].value }),
        handleAs: 'json' 
      }).then(lang.hitch(this, function (result) {
        if (result.lists.length) {
          this.setSearch('"' + result.lists.join('"|"') + '"');
        }
        else {
          this.setSearch('"_"');
        }

        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iWebfilter.entrySearchAlert)
        );
      }), xhrerror);
    },

    destroy: function () {
      this.inherited(arguments);
    }
  });
});


