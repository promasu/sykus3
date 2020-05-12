define([
  'dojo/_base/declare',
  'dojo/on',
  'dojo/query',
  'dojo/store/JsonRest',
  'dojo/dom-construct',
  '../../common/apiStore',
  '../../common/Form',
  '../../common/Chooser',
  '../../common/MultiChooser',
  '../../common/ChooserConfigPrinterDriver',
  '../../common/ChooserConfigHostGroup',
  '../../session/identity',
  'dojo/i18n!./nls/common'
],
function (
  declare, on, query, JsonRest, domConstruct,
  apiStore, Form, Chooser, MultiChooser,
  ChooserConfigPrinterDriver, ChooserConfigHostGroup,
  identity, iPrinters
) {
  return declare([ Form ], {
    constructor: function () {
      var DriverChooser, HGChooser, discoveredStore;

      identity.enforcePermission('printers_write');

      this.inherited(arguments);

      this.store = apiStore('/api/printers/');
      this.hostGroupStore = apiStore('/api/hostgroups/');
      this.driverStore = apiStore('/api/printers/drivers/', true);

      DriverChooser = declare([ ChooserConfigPrinterDriver, Chooser ], {});
      HGChooser = declare([ ChooserConfigHostGroup, MultiChooser ], {});

      this.driverChooser = new DriverChooser(
        query('[data-field="driver"]')[0],
        query('.js-dropdown-driver')[0]
      );

      this.hgChooser = new HGChooser(
        query('[data-field="hg-chooser"]')[0],
        query('.js-dropdown-hg-chooser')[0],
        query('.js-hg-list')[0]
      );

      discoveredStore = new JsonRest({ target: '/api/printers/discovered/' });

      discoveredStore.query({}).forEach(function (printer) {
        var target = query('.js-discovered div')[0], node;

        node = domConstruct.create('a', {
          href: '#',
          innerHTML: printer.name + ' (' + printer.url + ')'
        }, target, 'last');

        domConstruct.create('br', {}, target, 'last');

        on(node, 'click', function (e) {
          e.preventDefault();
          query('[data-field="url"]')[0].value = printer.url;
        });

        query('.js-discovered').removeClass('hide');
      });

    },

    validateCallback: function (field) { 
      switch (field) {
        case 'name':
          return (this.getField(field).value !== '') ? 
          true : iPrinters.validateName;

        case 'url': // server-side checking
          return (this.getField(field).value !== '') ? 
          true : iPrinters.validateURL;

        case 'driver':
          return (this.getField(field).value !== '') ? 
          true : iPrinters.validateDriver;
      }
      throw false;
    },

    mergePrinterData: function (data) {
      data.driver = this.driverStore.query({ name: data.driver })[0].id;
      data.host_groups = this.hgChooser.getMemberIdArray();
      return data;
    }

  });
});
