define([
  'dojo/_base/declare',
  'dojo/hash',
  './UserGroupForm',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  'mustache/mustache',
  'dojo/text!./templates/UserGroupCreate.html',
  'dojo/text!./templates/UserGroupForm.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, hash, UserGroupForm, bootstrap, nav, xhrerror, mustache, 
  tUserGroupCreate, tUserGroupForm, iUsers, iCommon
) {

  return declare([ UserGroupForm ], {
    constructor: function () {
      if (hash().match(/^admin/)) {
        nav.set('admin', 'users', 'usergroups');
      }
      else {
        nav.set('user', 'teacher', 'usergroups');
      }

      this.template = mustache.render(tUserGroupCreate, {
        iCommon: iCommon,
        iUsers: iUsers,
        backLink: (hash().match(/^admin/)) ? 
        'admin/users/UserGroupList' : 'teacher/UserGroupList'
      }, {
        UserGroupForm: tUserGroupForm
      });
      this.inherited(arguments);
    },

    submitCallback: function (data) {
      data = this.mergeUserGroupData(data);

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iUsers.userGroupCreatedAlert, data)
        );

        if (hash().match(/^admin/)) {
          hash('admin/users/UserGroupList');
        }
        else {
          hash('teacher/UserGroupList');
        }
      }, xhrerror);
    },

    destroy: function () { }
  });
});
