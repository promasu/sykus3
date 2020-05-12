define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/hash',
  'dojo/_base/array',
  './PrinterForm',
  '../../bootstrap',
  '../../nav',
  'mustache/mustache',
  '../../common/apiStore',
  '../../xhrerror',
  'dojo/text!./templates/PrinterUpdate.html',
  'dojo/text!./templates/PrinterForm.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
],
function (
  declare, lang, hash, array, PrinterForm, bootstrap, nav, mustache, apiStore, 
  xhrerror, tPrinterUpdate, tPrinterForm, iPrinters, iCommon
) {
  return declare([ PrinterForm ], {
    printer: null,

    constructor: function (printerId) {
      nav.set('admin', 'printers', 'printers');
      var store = apiStore('/api/printers/');

      this.template = mustache.render(tPrinterUpdate, {
        iCommon: iCommon,
        iPrinters: iPrinters
      }, {
        PrinterForm: tPrinterForm
      });

      this.inherited(arguments);

      apiStore.allReady().then(lang.hitch(this, function () {
        this.printer = store.get(printerId);

        if (!this.printer) {
          hash('admin/printers/PrinterList');
          return;
        }

        this.printer.driver = this.driverStore.get(this.printer.driver).name;

        this.hgChooser.setData(array.map(this.printer.host_groups, 
          lang.hitch(this, function (item) {
            return this.hostGroupStore.get(item);
          })
        ));

        this.setFormData(this.printer);
      }));
    },


    submitCallback: function (data) {
      data.id = this.printer.id;
      data = this.mergePrinterData(data);

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iPrinters.printerUpdatedAlert, data)
        );

        hash('admin/printers/PrinterList');
      }, xhrerror);
    },

    destroy: function () {
    }
  });
});
