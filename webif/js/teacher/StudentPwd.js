define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  'dojo/store/JsonRest',
  '../common/Grid',
  '../common/apiStore',
  'mustache/mustache',
  '../bootstrap',
  '../nav',
  '../xhrerror',
  '../session/identity',
  'dojo/text!./templates/StudentPwdList.html',
  'dojo/text!./templates/StudentPwdListEntry.html',
  'dojo/text!../common/templates/gridFilter.html',
  'dojo/text!../common/templates/partialPopover.html',
  'dojo/i18n!../admin/users/nls/common',
  'dojo/i18n!./nls/studentpwd',
  'dojo/i18n!../common/nls/common',
  'dojo/i18n!../common/nls/grid'
], 
function (
  declare, domConstruct, on, query, lang, JsonRest,
  Grid, apiStore, mustache, bootstrap, nav, xhrerror, identity,
  tUserList, tUserListEntry, tGridFilter, 
  tPartialPopover, iUsers, iStudentPwd, iCommon, iGrid
) {
  // warning: this module depends on i18n for admin/users
  return declare([ Grid ], {
    api: '/api/users/',
    domTable: 'StudentPwdTable',
    tRow: tUserListEntry,

    constructor: function () {
      nav.set('user', 'teacher', 'studentpwd');
      identity.enforcePermission('users_read');
      identity.enforcePermission('teacher_studentpwd');

      this.userClassStore = apiStore('/api/userclasses/');

      var tcUserList = mustache.render(tUserList, {
        iCommon: iCommon,
        iGrid: iGrid,
        iStudentPwd: iStudentPwd,
        iUsers: iUsers
      }, {
        gridFilter: tGridFilter
      });

      domConstruct.place(tcUserList, 'main', 'only');

      // wait for user class store 
      apiStore.allReady().then(lang.hitch(this, 
        lang.partial(this.inherited, arguments)));
    },

    filterQueryCallback: function (item) {
      if (item.position_group !== 'student') {
        return false;
      }

      if (item.admin_group !== 'none') {
        return false;
      }

      return true;
    },

    dataValueCallback: function (field, value) {
      switch (field) {
        case 'user_class':
          return this.userClassStore.get(value).name;

        default: return value;
      }
    },

    rowClickCallback: function (rowId, rowNode) {
      var template, node, cb, ref;

      ref = query(':nth-child(2)', rowNode)[0];

      template = mustache.render(tPartialPopover, {
        user: this.store.get(rowId), 
        popoverButtonClass: 'btn-warning'
      }, {
        popoverTitle: iUsers.passwordReset,
        popoverText: iUsers.passwordResetText,
        popoverButton: iUsers.passwordResetButton
      });
      node = bootstrap.showPopover(template, ref, 'right');

      cb = lang.hitch(this, lang.partial(this.passwordReset, rowId, ref));
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

    destroy: function () {
      this.inherited(arguments);
    }
  });
});

