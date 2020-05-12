define([
  'dojo/_base/declare',
  'dojo/_base/array',
  'dojo/dom-construct',
  'dojo/_base/lang',
  '../../common/Grid',
  'mustache/mustache',
  '../../nav',
  '../../session/identity',
  'dojo/text!./templates/ServiceLogs.html',
  'dojo/text!./templates/ServiceLogsEntry.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, array, domConstruct, lang, Grid, mustache, nav, identity,
  tServiceLogs, tServiceLogsEntry, tGridFilter, iLogs, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/logs/service/',
    sortDesc: true,

    domTable: 'ServiceLogsTable',
    tRow: tServiceLogsEntry,

    constructor: function () {
      nav.set('admin', 'logs', 'servicelogs');
      identity.enforcePermission('logs_read');

      var tcServiceLogs = mustache.render(tServiceLogs, {
        iCommon: iCommon,
        iGrid: iGrid,
        iLogs: iLogs
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcServiceLogs, 'main', 'only');

      this.inherited(arguments);
    },

    formatObject: function (obj) {
      var key, out = [];

      if (obj instanceof Array) {
        return array.map(obj, lang.hitch(this, this.formatObject)).join(', ');
      }

      if (obj instanceof Object) {
        for (key in obj) {
          if (obj.hasOwnProperty(key)) {
            out.push('<strong>' + key + ':</strong> ' + 
              this.formatObject(obj[key]));
          }
        }
        return out.join(', ');
      }

      return '' + obj;
    },

    dataValueCallback: function (field, value) {
      switch (field) {
        case 'input':
        case 'output':
          return this.formatObject(JSON.parse(value));

        default: 
          return value;
      }
    }

  });
});

