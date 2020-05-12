define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  '../../common/Grid',
  'mustache/mustache',
  '../../nav',
  '../../session/identity',
  'dojo/text!./templates/SessionLogs.html',
  'dojo/text!./templates/SessionLogsEntry.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, domConstruct, Grid, mustache, nav, identity,
  tSessionLogs, tSessionLogsEntry, tGridFilter, iLogs, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/logs/session/',
    sortDesc: true,

    domTable: 'SessionLogsTable',
    tRow: tSessionLogsEntry,

    constructor: function () {
      nav.set('admin', 'logs', 'sessionlogs');
      identity.enforcePermission('logs_read');

      var tcSessionLogs = mustache.render(tSessionLogs, {
        iCommon: iCommon,
        iGrid: iGrid,
        iLogs: iLogs
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcSessionLogs, 'main', 'only');

      this.inherited(arguments);
    },

    dataValueCallback: function (field, value) {
      if (field === 'type') {
        switch (value) {
          case 'host_login': return iLogs.sessionTypeHostLogin;
          case 'login': return iLogs.sessionTypeLogin;
          case 'auth': return iLogs.sessionTypeAuth;
          default: return value;
        }
      }
      return value;
    }

  });
});

