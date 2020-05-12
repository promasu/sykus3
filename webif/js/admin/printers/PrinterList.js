define([
  'dojo/_base/declare',
  'dojo/_base/array',
  'dojo/dom-construct',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  'dojo/store/JsonRest',
  '../../common/Grid',
  '../../common/apiStore',
  'mustache/mustache',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  '../../session/identity',
  'dojo/text!./templates/PrinterList.html',
  'dojo/text!./templates/PrinterListEntry.html',
  'dojo/text!./templates/PrinterListAction.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/text!../../common/templates/partialPopover.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, array, domConstruct, on, query, lang, JsonRest,
  Grid, apiStore, mustache, bootstrap, nav, xhrerror, identity,
  tPrinterList, tPrinterListEntry, tPrinterListAction, tGridFilter, 
  tPartialPopover, iPrinters, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/printers/',
    domTable: 'PrinterListTable',
    tRow: tPrinterListEntry,

    constructor: function () {
      nav.set('admin', 'printers', 'printers');
      identity.enforcePermission('printers_read');

      this.hostGroupStore = apiStore('/api/hostgroups/');
      this.driverStore = apiStore('/api/printers/drivers/', true);

      var tcPrinterList = mustache.render(tPrinterList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iPrinters: iPrinters
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcPrinterList, 'main', 'only');

      if (identity.permission('printers_write')) {
        query('.js-btn-create').removeClass('hide');
      }

      // wait for host group store 
      apiStore.allReady().then(lang.hitch(this, 
        lang.partial(this.inherited, arguments)));
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, ref, node;

      if (!identity.permission('printers_write')) {
        return;
      }

      template = mustache.render(tPrinterListAction, {
        data: this.store.get(rowId),
        iPrinters: iPrinters
      });

      ref = query(':first-child', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.js-btn-reset', node), 
        'click', 
        lang.hitch(this, lang.partial(this.resetPrinterPopover, rowId, ref))
      );

      on(
        query('.js-btn-delete', node), 
        'click', 
        lang.hitch(this, lang.partial(this.deletePrinterPopover, rowId, ref))
      );
    },

    dataValueCallback: function (field, value) {
      switch (field) {
        case 'driver':
          return this.driverStore.get(value).name;

        default: return value;
      }
    },

    compileData: function (data) {
      data.hgShow = array.map(data.host_groups, 
        lang.hitch(this, function (id) {
          return this.hostGroupStore.get(id).name;
        })
      ).join(', ');

      return this.inherited(arguments);
    },

    resetPrinterPopover: function (id, ref) {
      var template, node, cb;

      template = mustache.render(tPartialPopover, {
        printer: this.store.get(id), 
        popoverButtonClass: 'btn-warning'
      }, {
        popoverTitle: iPrinters.resetPrinter,
        popoverText: iPrinters.resetText,
        popoverButton: iPrinters.resetButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.resetPrinter, id, ref));
      on(query('.js-btn-confirm', node), 'click', cb);
    },

    resetPrinter: function (id) {
      var resetStore = new JsonRest({ 
        target: '/api/printers/' + id + '/reset' 
      });

      resetStore.put({}).then(lang.hitch(this, function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iPrinters.resetAlert, this.store.get(id))
        );
      }), xhrerror);
    },

    deletePrinterPopover: function (id, ref) {
      var template, node, cb;

      template = mustache.render(tPartialPopover, {
        printer: this.store.get(id), 
        popoverButtonClass: 'btn-danger'
      }, {
        popoverTitle: iPrinters.deletePrinter,
        popoverText: iPrinters.printerDeleteText,
        popoverButton: iPrinters.printerDeleteButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.deletePrinter, id));
      on(query('.js-btn-confirm', node), 'click', cb);
    },

    deletePrinter: function (id) {
      var printer = this.store.get(id);

      this.store.remove(id).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iPrinters.printerDeletedAlert, printer)
        );
      }, xhrerror);
    },

    destroy: function () {
      this.inherited(arguments);
    }
  });
});

