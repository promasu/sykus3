define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  'dojo/store/JsonRest',
  '../../common/Grid',
  '../../common/Chooser',
  '../../common/ChooserConfigHostGroup',
  '../../common/apiStore',
  'mustache/mustache',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  '../../session/identity',
  'dojo/text!./templates/HostList.html',
  'dojo/text!./templates/HostListEntry.html',
  'dojo/text!./templates/HostListAction.html',
  'dojo/text!./templates/HostUpdate.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/text!../../common/templates/partialPopover.html',
  'dojo/text!../../common/templates/partialPopoverInfo.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, domConstruct, on, query, lang, JsonRest,
  Grid, Chooser, ChooserConfigHostGroup,
  apiStore, mustache, bootstrap, nav, xhrerror, identity,
  tHostList, tHostListEntry, tHostListAction, tHostUpdate, tGridFilter, 
  tPartialPopover, tPartialPopoverInfo, iHosts, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/hosts/',
    domTable: 'HostListTable',
    tRow: tHostListEntry,

    constructor: function () {
      nav.set('admin', 'hosts', 'hosts');
      identity.enforcePermission('hosts_read');

      this.hostGroupStore = apiStore('/api/hostgroups/');

      var tcHostList = mustache.render(tHostList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iHosts: iHosts
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcHostList, 'main', 'only');

      if (identity.permission('hosts_create')) {
        query('.js-btn-create').removeClass('hide');
        on(
          query('.js-btn-create'), 
          'click', 
          lang.hitch(this, lang.partial(this.createHostPopover))
        );
      }

      // wait for host group store 
      apiStore.allReady().then(lang.hitch(this, 
        lang.partial(this.inherited, arguments)));
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, ref, node;

      if (!identity.permission('hosts_update_delete')) {
        return;
      }

      template = mustache.render(tHostListAction, {
        data: this.store.get(rowId),
        iHosts: iHosts
      });

      ref = query(':nth-child(2)', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.js-btn-update', node), 
        'click', 
        lang.hitch(this, lang.partial(this.updateHostPopover, rowId, ref))
      );

      on(
        query('.js-btn-reinstall', node), 
        'click', 
        lang.hitch(this, lang.partial(this.reinstallHostPopover, rowId, ref))
      );

      on(
        query('.js-btn-delete', node), 
        'click', 
        lang.hitch(this, lang.partial(this.deleteHostPopover, rowId, ref))
      );
    },

    dataValueCallback: function (field, value) {
      switch (field) {
        case 'online':
          return value ? iHosts.onlineTrue : iHosts.onlineFalse;

        case 'ready':
          return value ? iCommon.yes : iCommon.no;

        case 'host_group':
          return this.hostGroupStore.get(value).name;

        default: return value;
      }
    },

    dataTitleCallback: function (field, value) {
      switch (field) {
        case 'cpu_speed':
          return iHosts.cpuSpeedTitle;

        case 'ready':
          return value ? iHosts.readyTrueTitle : iHosts.readyFalseTitle;

        default: return '';
      }
    },

    dataClassCallback: function (field, value) {
      switch (field) {

        case 'online':
          return value ? 'color-yes' : '';
        
        case 'ready':
          return value ? 'color-yes' : 'color-no';

        default: return '';
      }
    },

    createHostPopover: function () {
      var template;

      template = mustache.render(tPartialPopoverInfo, { }, {
        popoverTitle: iHosts.createHostTitle,
        popoverText: iHosts.createHostText
      });
      bootstrap.showPopover(template, query('.js-btn-create')[0], 'left');
    },

    reinstallHostPopover: function (id, ref) {
      var template, node, cb;

      template = mustache.render(tPartialPopover, {
        host: this.store.get(id), 
        popoverButtonClass: 'btn-warning'
      }, {
        popoverTitle: iHosts.reinstallHost,
        popoverText: iHosts.reinstallHostText,
        popoverButton: iHosts.reinstallHostButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.reinstallHost, id));
      on(query('.js-btn-confirm', node), 'click', cb);
    },

    reinstallHost: function (id) {
      var reinstallStore = new JsonRest({ 
        target: '/api/hosts/' + id + '/reinstall' 
      });

      reinstallStore.put({}).then(lang.hitch(this, function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iHosts.reinstallHostAlert, this.store.get(id))
        );
      }), xhrerror);
    },

    updateHostPopover: function (id, ref) {
      var template, node, GroupChooser, host;

      host = this.store.get(id);
      template = mustache.render(tHostUpdate, {
        iHosts: iHosts,
        iCommon: iCommon,
        host: host,
        hostGroupName: this.hostGroupStore.get(host.host_group).name
      });

      node = bootstrap.showPopover(template, ref, 'right');
      query('.js-name', node)[0].focus();

      GroupChooser = declare([ ChooserConfigHostGroup, Chooser ], {});

      node.groupChooser = new GroupChooser(
        query('.js-host-group', node)[0],
        query('.js-dropdown-host-group', node)[0]
      );

      on(
        query('.js-update-form', node),
        'submit', 
        lang.hitch(this, lang.partial(this.updateHost, id))
      );
    },

    updateHost: function (id, e) {
      var data = {
        id: id,
        name: query('.js-name')[0].value,
        host_group: this.hostGroupStore.query({
          name: query('.js-host-group')[0].value
        })[0].id
      };

      e.preventDefault();

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iHosts.hostUpdatedAlert, data)
        );
      }, xhrerror);
    },

    deleteHostPopover: function (id, ref) {
      var template, node, cb;

      template = mustache.render(tPartialPopover, {
        host: this.store.get(id), 
        popoverButtonClass: 'btn-danger'
      }, {
        popoverTitle: iHosts.deleteHost,
        popoverText: iHosts.hostDeleteText,
        popoverButton: iHosts.hostDeleteButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.deleteHost, id));
      on(query('.js-btn-confirm', node), 'click', cb);
    },

    deleteHost: function (id) {
      var host = this.store.get(id);

      this.store.remove(id).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iHosts.hostDeletedAlert, host)
        );
      }, xhrerror);
    },

    destroy: function () {
      this.inherited(arguments);
    }
  });
});

