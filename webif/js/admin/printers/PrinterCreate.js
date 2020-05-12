define([
  'dojo/_base/declare',
  'dojo/hash',
  './PrinterForm',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  'mustache/mustache',
  'dojo/text!./templates/PrinterCreate.html',
  'dojo/text!./templates/PrinterForm.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, hash, PrinterForm, bootstrap, nav, xhrerror, mustache, 
  tPrinterCreate, tPrinterForm, iPrinters, iCommon
) {

  return declare([ PrinterForm ], {
    constructor: function () {
      nav.set('admin', 'printers', 'printers');
      this.template = mustache.render(tPrinterCreate, {
        iCommon: iCommon,
        iPrinters: iPrinters
      }, {
        PrinterForm: tPrinterForm
      });
      this.inherited(arguments);
    },

    submitCallback: function (data) {
      data = this.mergePrinterData(data);

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iPrinters.printerCreatedAlert, data)
        );

        hash('admin/printers/PrinterList');
      }, xhrerror);
    },

    destroy: function () {
    }
  });
});

