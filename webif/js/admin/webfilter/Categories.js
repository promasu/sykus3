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
  'dojo/text!./templates/CategoryList.html',
  'dojo/text!./templates/CategoryListEntry.html',
  'dojo/text!./templates/CategoryListAction.html',
  'dojo/text!./templates/CategorySearch.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, domConstruct, request, on, query, lang, Grid, mustache, bootstrap, 
  nav, xhrerror, identity, tCategoryList, tCategoryListEntry, 
  tCategoryListAction, tCategorySearch, tGridFilter, iWebfilter, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/webfilter/categories/',
    domTable: 'CategoryListTable',
    tRow: tCategoryListEntry,

    constructor: function () {
      nav.set('admin', 'webfilter', 'categories');
      identity.enforcePermission('webfilter_read');

      var tcCategoryList = mustache.render(tCategoryList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iWebfilter: iWebfilter
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcCategoryList, 'main', 'only');

      on(
        query('.js-btn-search'), 
        'click', 
        lang.hitch(this, this.searchPopover)
      );

      this.inherited(arguments);
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, ref, node;

      if (!identity.permission('webfilter_write')) {
        return;
      }

      template = mustache.render(tCategoryListAction, {
        data: this.store.get(rowId),
        iWebfilter: iWebfilter
      });

      ref = query(':first-child', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.js-btn-all', node), 
        'click', 
        lang.hitch(this, lang.partial(this.selectCategory, rowId, 'all'))
      );
      on(
        query('.js-btn-students', node), 
        'click', 
        lang.hitch(this, lang.partial(this.selectCategory, rowId, 'students'))
      );
      on(
        query('.js-btn-none', node), 
        'click', 
        lang.hitch(this, lang.partial(this.selectCategory, rowId, 'none'))
      );
    },

    dataValueCallback: function (field, value) {
      switch (field) {
        case 'default':
          switch (value) {
            case 'all': return iWebfilter.categoryDefaultAll;
            case 'students': return iWebfilter.categoryDefaultStudents;
            case 'none': return iWebfilter.categoryDefaultNone;
          }
          throw false;

        case 'selected':
          switch (value) {
            case 'all': return iWebfilter.categorySelectedAll;
            case 'students': return iWebfilter.categorySelectedStudents;
            case 'none': return iWebfilter.categorySelectedNone;
          }
          throw false;

        default: return value;
      }
    },

    dataTitleCallback: function (field, value) {
      switch (field) {
        case 'default':
          switch (value) {
            case 'all': return iWebfilter.categoryDefaultAllTitle;
            case 'students': return iWebfilter.categoryDefaultStudentsTitle;
            case 'none': return iWebfilter.categoryDefaultNoneTitle;
          }
          throw false;

        case 'selected':
          switch (value) {
            case 'all': return iWebfilter.categorySelectedAllTitle;
            case 'students': return iWebfilter.categorySelectedStudentsTitle;
            case 'none': return iWebfilter.categorySelectedNoneTitle;
          }
          throw false;

        default: return '';
      }
    },

    dataClassCallback: function (field, value, item) {
      switch (field) {
        case 'default':
          switch (value) {
            case 'all': return 'label-success';
            case 'students': return 'label-info';
            case 'none': return 'label-default';
          }
          throw false;

        case 'selected':
          switch (value) {
            case 'all': return 'label-success';
            case 'students': return 'label-info';
            case 'none': 
              return (item['default'] !== 'none') ? 
              'label-danger' : 'label-default';
          }
          throw false;

        default: return '';
      }
    },

    selectCategory: function (id, selected) {
      var data = {
        id: id,
        selected: selected
      };

      this.store.put(data).then(lang.hitch(this, function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iWebfilter.categorySelectedAlert, this.store.get(id))
        );
      }, xhrerror));
    },

    searchPopover: function () {
      var template, node, ref;

      ref = query('.js-btn-search')[0];
      template = mustache.render(tCategorySearch, {
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
          mustache.render(iWebfilter.categorySearchAlert)
        );
      }), xhrerror);
    },

    destroy: function () {
      this.inherited(arguments);
    }
  });
});


