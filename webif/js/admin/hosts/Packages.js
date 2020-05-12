define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/dom-class',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  'dojo/request',
  '../../common/Grid',
  'mustache/mustache',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  '../../session/identity',
  'dojo/text!./templates/PackageList.html',
  'dojo/text!./templates/PackageListEntry.html',
  'dojo/text!./templates/PackageListAction.html',
  'dojo/text!./templates/ImageAction.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, domConstruct, domClass, on, query, lang, request, 
  Grid, mustache, bootstrap, nav, xhrerror, identity,
  tPackageList, tPackageListEntry, tPackageListAction, 
  tImageAction, tGridFilter, 
  iHosts, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/packages/',
    domTable: 'PackageListTable',
    tRow: tPackageListEntry,

    constructor: function () {
      nav.set('admin', 'hosts', 'packages');
      identity.enforcePermission('packages_read');

      var tcPackageList = mustache.render(tPackageList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iHosts: iHosts
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcPackageList, 'main', 'only');

      if (identity.permission('image_create')) {
        on(
          query('.js-btn-image'), 
          'click', 
          lang.hitch(this, lang.partial(this.createImagePopover))
        );
      }

      this.imagePollTimer = setInterval(
        lang.hitch(this, this.pollImageState), 
        1500
      );
      this.pollImageState();

      this.inherited(arguments);
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, ref, node;

      if (!identity.permission('packages_write')) {
        return;
      }

      template = mustache.render(tPackageListAction, {
        data: this.store.get(rowId),
        iHosts: iHosts
      });

      ref = query(':nth-child(2)', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.js-btn-select', node), 
        'click', 
        lang.hitch(this, lang.partial(this.selectPackage, rowId, ref))
      );
    },

    dataValueCallback: function (field, value) {
      switch (field) {
        case 'default':
          return value ? iHosts.packageDefaultTrue : 
          iHosts.packageDefaultFalse;

        case 'selected':
        case 'installed':
          return value ? iCommon.yes : iCommon.no;

        default: return value;
      }
    },

    dataTitleCallback: function (field, value) {
      switch (field) {
        case 'default':
          return value ? iHosts.packageDefaultTrueTitle : 
          iHosts.packageDefaultFalseTitle;

        case 'selected':
          return value ? iHosts.packageSelectedTrueTitle : 
          iHosts.packageSelectedFalseTitle;

        case 'installed':
          return value ? iHosts.packageInstalledTrueTitle : 
          iHosts.packageInstalledFalseTitle;

        default: return '';
      }
    },

    dataClassCallback: function (field, value, item) {
      switch (field) {
        case 'default':
          return value ? 'color-yes' : '';

        case 'selected':
        case 'installed':
          return value ? 'color-yes' : (item['default'] ? 'color-no' : '');

        default: return '';
      }
    },

    pollImageState: function () {
      request.get('/api/image', { handleAs: 'json' }).
      then(lang.hitch(this, function (res) {
        var btn = query('.js-btn-image')[0]; 
        this.imageState = res;

        domClass.remove(btn, 'btn-success btn-warning btn-danger');
        switch (res) {
          case 'idle':
            domClass.add(btn, 'btn-success');
            this.imageStateText = btn.innerHTML = iHosts.imageStateIdle;
            break;

          case 'scheduled':
            domClass.add(btn, 'btn-warning');
            this.imageStateText = btn.innerHTML = iHosts.imageStateScheduled;
            break;

          case 'running':
            domClass.add(btn, 'btn-danger');
            this.imageStateText = btn.innerHTML = iHosts.imageStateRunning;
            break;
        }
      }), xhrerror);
    },

    createImagePopover: function () {
      var template, ref, node;

      template = mustache.render(tImageAction, { 
        isIdle: (this.imageState === 'idle'),
        state: this.imageStateText,
        iHosts: iHosts
      });

      ref = query('.js-btn-image')[0];
      node = bootstrap.showPopover(template, ref, 'left');

      on(
        query('.js-btn-abort', node), 
        'click', 
        lang.hitch(this, lang.partial(this.abortImage))
      );
      on(
        query('.js-btn-create', node), 
        'click', 
        lang.hitch(this, lang.partial(this.createImage, false))
      );

      on(
        query('.js-btn-create-now', node), 
        'click', 
        lang.hitch(this, lang.partial(this.createImage, true))
      );
    },

    selectPackage: function (id) {
      var data = {
        id: id,
        selected: !this.store.get(id).selected
      };

      this.store.put(data).then(lang.hitch(this, function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iHosts.packageSelectedAlert, this.store.get(id))
        );
      }, xhrerror));
    },

    createImage: function (now) {
      var args = { 
        data: JSON.stringify({ now: now }) 
      };
      request.post('/api/image', args).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iHosts.createImageAlert)
        );
      }, xhrerror);
    },

    abortImage: function () {
      request.del('/api/image').then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iHosts.abortImageAlert)
        );
      }, xhrerror);
    },


    destroy: function () {
      clearInterval(this.imagePollTimer);
      this.inherited(arguments);
    }
  });
});


