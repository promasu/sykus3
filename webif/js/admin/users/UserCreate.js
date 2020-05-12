define([
  'dojo/_base/declare',
  'dojo/hash',
  './UserForm',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  'mustache/mustache',
  'dojo/text!./templates/UserCreate.html',
  'dojo/text!./templates/UserForm.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, hash, UserForm, bootstrap, nav, xhrerror, mustache, tUserCreate, 
  tUserForm, iUsers, iCommon
) {
  return declare([ UserForm ], {
    constructor: function () {
      nav.set('admin', 'users', 'users');

      this.template = mustache.render(tUserCreate, {
        iCommon: iCommon,
        iUsers: iUsers
      }, {
        UserForm: tUserForm
      });
      this.inherited(arguments);
    },

    submitCallback: function (data) {
      data = this.mergeUserData(data);

      if (!this.confirmDuplicate(data) ||
      !this.confirmAdmin(data, 'none')) {
        return;
      }

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iUsers.userCreatedAlert, data)
        );

        hash('admin/users/UserList');
      }, xhrerror);
    },

    destroy: function () {
    }
  });
});

