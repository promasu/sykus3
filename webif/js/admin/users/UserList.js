define([
  'dojo/_base/declare',
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
  'dojo/text!./templates/UserList.html',
  'dojo/text!./templates/UserListEntry.html',
  'dojo/text!./templates/UserListAction.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/text!../../common/templates/partialPopover.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, domConstruct, on, query, lang, JsonRest,
  Grid, apiStore, mustache, bootstrap, nav, xhrerror, identity,
  tUserList, tUserListEntry, tUserListAction, tGridFilter, 
  tPartialPopover, iUsers, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/users/',
    domTable: 'UserListTable',
    tRow: tUserListEntry,

    constructor: function () {
      nav.set('admin', 'users', 'users');
      identity.enforcePermission('users_read');

      this.userClassStore = apiStore('/api/userclasses/');

      var tcUserList = mustache.render(tUserList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iUsers: iUsers
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcUserList, 'main', 'only');

      if (identity.permission('users_write')) {
        query('.js-btn-create').removeClass('hide');
      }

      // wait for user class store 
      apiStore.allReady().then(lang.hitch(this, 
        lang.partial(this.inherited, arguments)));
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, ref, node;

      if (!identity.permission('users_write')) {
        return;
      }

      template = mustache.render(tUserListAction, {
        data: this.store.get(rowId),
        iUsers: iUsers
      });

      ref = query(':nth-child(2)', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.js-btn-passwordreset', node), 
        'click', 
        lang.hitch(this, lang.partial(this.passwordResetPopover, rowId, ref))
      );

      on(
        query('.js-btn-delete', node), 
        'click', 
        lang.hitch(this, lang.partial(this.deleteUserPopover, rowId, ref))
      );
    },

    getQuotaString: function (user) {
      var percent;

      percent = user.quota_used_mb * 100.0 / user.quota_total_mb;
      return user.quota_used_mb + ' MB [' + Math.ceil(percent) + ' %]';
    },

    dataValueCallback: function (field, value, user) {
      switch (field) {
        case 'position_group':
          switch (value) {
            case 'person': return iUsers.positionPerson;
            case 'student': return iUsers.positionStudent;
            case 'teacher': return iUsers.positionTeacher;
          }
          throw false;

        case 'admin_group':
          switch (value) {
            case 'none': return iUsers.adminNoneShort;
            case 'junior': return iUsers.adminJuniorShort;
            case 'senior': return iUsers.adminSeniorShort;
            case 'super': return iUsers.adminSuperShort;
          }
          throw false;

        case 'user_class':
          return (value > 0) ? this.userClassStore.get(value).name : '';

        case 'quota_used_mb':
          return this.getQuotaString(user);

        default: return value;
      }
    },

    dataTitleCallback: function (field, value) {
      switch (field) {
        case 'position_group':
          switch (value) {
            case 'person': return iUsers.positionPersonText;
            case 'student': return iUsers.positionStudentText;
            case 'teacher': return iUsers.positionTeacherText;
          }
          throw false;

        case 'admin_group':
          switch (value) {
            case 'none': return iUsers.adminNoneText;
            case 'junior': return iUsers.adminJuniorText;
            case 'senior': return iUsers.adminSeniorText;
            case 'super': return iUsers.adminSuperText;
          }
          throw false;

        default: return '';
      }
    },

    dataClassCallback: function (field, value) {
      switch (field) {
        case 'position_group':
          switch (value) {
            case 'person': return 'color-person';
            case 'student': return 'color-student'; 
            case 'teacher': return 'color-teacher';
          }
          throw false;

        case 'admin_group':
          switch (value) {
            case 'none': return '';
            case 'junior': return 'color-admin-junior';
            case 'senior': return 'color-admin-senior';
            case 'super': return 'color-admin-super';
          }
          throw false;

        default: return '';
      }
    },

    passwordResetPopover: function (id, ref) {
      var template, node, cb;

      template = mustache.render(tPartialPopover, {
        user: this.store.get(id), 
        popoverButtonClass: 'btn-warning'
      }, {
        popoverTitle: iUsers.passwordReset,
        popoverText: iUsers.passwordResetText,
        popoverButton: iUsers.passwordResetButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.passwordReset, id, ref));
      on(query('.js-btn-confirm', node), 'click', cb);
    },

    passwordReset: function (id, ref) {
      var template, resetStore;

      resetStore = new JsonRest({ 
        target: '/api/users/' + id + '/passwordreset' 
      });
      resetStore.put({}).then(lang.hitch(this, function (res) {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iUsers.passwordResetAlert, this.store.get(id))
        );

        template = mustache.render(tPartialPopover, {
          user: this.store.get(id),
          password: res.password
        }, {
          popoverTitle: iUsers.passwordResetResult,
          popoverText: iUsers.passwordResetResultText,
          popoverButton: iUsers.passwordResetResultButton
        });
        bootstrap.showPopover(template, ref, 'right');

      }), xhrerror);
    },

    deleteUserPopover: function (id, ref) {
      var template, node, cb;

      template = mustache.render(tPartialPopover, {
        user: this.store.get(id), 
        popoverButtonClass: 'btn-danger'
      }, {
        popoverTitle: iUsers.deleteUser,
        popoverText: iUsers.userDeleteText,
        popoverButton: iUsers.userDeleteButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.deleteUser, id));
      on(query('.js-btn-confirm', node), 'click', cb);
    },

    deleteUser: function (id) {
      var user = this.store.get(id);

      this.store.remove(id).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iUsers.userDeletedAlert, user)
        );
      }, xhrerror);
    },

    destroy: function () {
      this.inherited(arguments);
    }
  });
});

