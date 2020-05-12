define([
  'dojo/_base/declare',
  'dojo/_base/array',
  'dojo/dom-construct',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  '../../common/Grid',
  '../../common/apiStore',
  'mustache/mustache',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  '../../session/identity',
  'dojo/text!./templates/HostGroupList.html',
  'dojo/text!./templates/HostGroupListEntry.html',
  'dojo/text!./templates/HostGroupListAction.html',
  'dojo/text!./templates/HostGroupCreate.html',
  'dojo/text!./templates/HostGroupUpdate.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/text!../../common/templates/partialPopover.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, array, domConstruct, on, query, lang, 
  Grid, apiStore, mustache, bootstrap, nav, xhrerror, identity,
  tHostGroupList, tHostGroupListEntry, tHostGroupListAction, tHostGroupCreate,
  tHostGroupUpdate, tGridFilter, tPartialPopover, iHosts, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/hostgroups/',
    domTable: 'HostGroupListTable',
    tRow: tHostGroupListEntry,

    constructor: function () {
      nav.set('admin', 'hosts', 'hostgroups');
      var tcHostGroupList;

      identity.enforcePermission('host_groups_read');

      this.hostsStore = apiStore('/api/hosts/');

      tcHostGroupList = mustache.render(tHostGroupList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iHosts: iHosts
      }, {
        gridFilter: tGridFilter
      });
      domConstruct.place(tcHostGroupList, 'main', 'only');

      if (identity.permission('host_groups_write')) {
        query('.js-btn-create').removeClass('hide');
        on(
          query('.js-btn-create'), 
          'click', 
          lang.hitch(this, this.createPopover)
        );
      }

      apiStore.allReady().then(lang.hitch(this, 
        lang.partial(this.inherited, arguments)));
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, ref, node;

      if (!identity.permission('host_groups_write')) {
        return;
      }

      template = mustache.render(tHostGroupListAction, {
        data: this.compileData(this.store.get(rowId)).data,
        iHosts: iHosts
      });

      ref = query(':first-child', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.js-btn-update', node), 
        'click', 
        lang.hitch(this, lang.partial(this.updateGroupPopover, rowId, ref))
      );

      on(
        query('.js-btn-delete', node), 
        'click', 
        lang.hitch(this, lang.partial(this.deleteGroupPopover, rowId, ref))
      );
    },

    createPopover: function () {
      var template, node, ref;

      ref = query('.js-btn-create')[0];
      template = mustache.render(tHostGroupCreate, {
        iHosts: iHosts,
        iCommon: iCommon
      });

      node = bootstrap.showPopover(template, ref, 'left');
      query('.js-input-name', node)[0].focus();

      on(
        query('.js-create-form', node),
        'submit', 
        lang.hitch(this, this.create)
      );
    },

    create: function (e) {
      e.preventDefault();

      this.store.put({
        name: query('.js-input-name')[0].value
      }).then(lang.hitch(this, function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iHosts.hostGroupCreatedAlert)
        );
      }), xhrerror);
    },

    updateGroupPopover: function (id, ref) {
      var template, node, hostGroup;

      hostGroup = this.store.get(id);
      template = mustache.render(tHostGroupUpdate, {
        iHosts: iHosts,
        iCommon: iCommon,
        hostGroup: hostGroup
      });

      node = bootstrap.showPopover(template, ref, 'right');
      query('.js-name', node)[0].focus();

      on(
        query('.js-update-form', node),
        'submit', 
        lang.hitch(this, lang.partial(this.updateGroup, id))
      );
    },

    updateGroup: function (id, e) {
      var data = {
        id: id,
        name: query('.js-name')[0].value
      };

      e.preventDefault();

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iHosts.hostGroupUpdatedAlert, data)
        );
      }, xhrerror);
    },

    deleteGroupPopover: function (id, ref) {
      var template, node, cb;

      template = mustache.render(tPartialPopover, {
        hostGroup: this.compileData(this.store.get(id)).data,
        popoverButtonClass: 'btn-danger'
      }, {
        popoverTitle: iHosts.deleteHostGroup,
        popoverText: iHosts.hostGroupDeleteText,
        popoverButton: iHosts.hostGroupDeleteButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.deleteGroup, id));
      on(query('.js-btn-confirm', node), 'click', cb);
    },

    deleteGroup: function (id) {
      this.store.remove(id).then(function () {
        bootstrap.showAlert('alert-success', iHosts.hostGroupDeletedAlert);
      }, xhrerror);
    },

    compileData: function (data) {
      data.members = array.map(
        this.hostsStore.query({ 
          host_group: data.id
        }, {
          sort: [ { attribute: 'name', descending: false } ] 
        }),
        function (host) { return host.name; }
      ).join(', ');

      return this.inherited(arguments);
    },

    destroy: function () {
      this.inherited(arguments);
    }
  });
});

