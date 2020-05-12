define([
  'dojo/_base/declare',
  'dojo/_base/array',
  'dojo/dom-construct',
  'dojo/on',
  'dojo/hash',
  'dojo/query',
  'dojo/_base/lang',
  '../../common/Grid',
  '../../common/apiStore',
  'mustache/mustache',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  '../../session/identity',
  'dojo/text!./templates/UserGroupList.html',
  'dojo/text!./templates/UserGroupListEntry.html',
  'dojo/text!./templates/UserGroupListAction.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/text!../../common/templates/partialPopover.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, array, domConstruct, on, hash, query, lang, 
  Grid, apiStore, mustache, bootstrap, nav, xhrerror, identity,
  tUserGroupList, tUserGroupListEntry, tUserGroupListAction, tGridFilter, 
  tPartialPopover, iUsers, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/usergroups/',
    domTable: 'UserGroupListTable',
    tRow: tUserGroupListEntry,

    constructor: function () {
      var tcUserGroupList;

      identity.enforcePermission('user_groups_read');

      if (hash().match(/^admin/)) {
        nav.set('admin', 'users', 'usergroups');
      }
      else {
        nav.set('user', 'teacher', 'usergroups');
      }

      this.usersStore = apiStore('/api/users/');

      tcUserGroupList = mustache.render(tUserGroupList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iUsers: iUsers,
        showOwner: !!hash().match(/^admin/),
        createLink: (hash().match(/^admin/)) ? 
        'admin/users/UserGroupCreate' : 'teacher/UserGroupCreate'
      }, {
        gridFilter: tGridFilter
      });
      domConstruct.place(tcUserGroupList, 'main', 'only');

      if (identity.permission('user_groups_write') ||
      identity.permission('user_groups_write_own')) {
        query('.js-btn-create').removeClass('hide');
      }

      apiStore.allReady().then(lang.hitch(this, 
        lang.partial(this.inherited, arguments)));
    },

    filterQueryCallback: function (item) {
      if (!hash().match(/^admin/)) {
        if (item.owner !== identity.getUser().id) {
          return false;
        }
      }
      return true;
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, ref, node;

      if (!identity.permission('user_groups_write') &&
      !identity.permission('user_groups_write_own')) {
        return;
      }

      template = mustache.render(tUserGroupListAction, {
        data: this.compileData(this.store.get(rowId)).data,
        updateHash: (hash().match(/^admin/)) ? 
        'admin/users/UserGroupUpdate' : 'teacher/UserGroupUpdate',
        iUsers: iUsers
      });

      ref = query(':first-child', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.js-btn-delete', node), 
        'click', 
        lang.hitch(this, lang.partial(this.deleteGroupPopover, rowId, ref))
      );
    },

    deleteGroupPopover: function (id, ref) {
      var template, node, cb;

      template = mustache.render(tPartialPopover, {
        userGroup: this.compileData(this.store.get(id)).data,
        popoverButtonClass: 'btn-danger'
      }, {
        popoverTitle: iUsers.deleteUserGroup,
        popoverText: iUsers.userGroupDeleteText,
        popoverButton: iUsers.userGroupDeleteButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.deleteGroup, id));
      on(query('.js-btn-confirm', node), 'click', cb);
    },

    deleteGroup: function (id) {
      this.store.remove(id).then(function () {
        bootstrap.showAlert('alert-success', iUsers.userGroupDeletedAlert);
      }, xhrerror);
    },

    compileData: function (data) {
      data.users.sort(lang.hitch(this, function (a, b) {
        a = this.usersStore.get(a).username;
        b = this.usersStore.get(b).username;
        return a === b ? 0 : (a > b ? 1 : -1);
      }));

      data.usersShow = array.map(data.users, 
        lang.hitch(this, function (id) {
          var user = this.usersStore.get(id);
          return user.first_name + ' ' + user.last_name;
        })
      ).join(', ');

      data.showOwner = !!hash().match(/^admin/);

      return this.inherited(arguments);
    },

    dataValueCallback: function (field, value) {
      var user;
      if (field === 'owner') {
        user = this.usersStore.get(value);
        return user.first_name + ' ' + user.last_name;
      }
      return value;
    },

    destroy: function () {
      this.inherited(arguments);
    }
  });
});

