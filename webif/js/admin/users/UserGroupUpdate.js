define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/_base/array',
  'dojo/hash',
  './UserGroupForm',
  '../../bootstrap',
  '../../nav',
  '../../xhrerror',
  '../../common/apiStore',
  'mustache/mustache',
  'dojo/text!./templates/UserGroupUpdate.html',
  'dojo/text!./templates/UserGroupForm.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, lang, array, hash, UserGroupForm, bootstrap, nav, xhrerror, 
  apiStore, mustache, tUserGroupUpdate, tUserGroupForm, iUsers, iCommon
) {
  return declare([ UserGroupForm ], {
    constructor: function (userGroupId) { 
      if (hash().match(/^admin/)) {
        nav.set('admin', 'users', 'usergroups');
      }
      else {
        nav.set('user', 'teacher', 'usergroups');
      }

      this.template = mustache.render(tUserGroupUpdate, {
        iCommon: iCommon,
        iUsers: iUsers,
        backLink: (hash().match(/^admin/)) ? 
        'admin/users/UserGroupList' : 'teacher/UserGroupList'
      }, {
        UserGroupForm: tUserGroupForm
      });

      this.inherited(arguments);

      apiStore.allReady().then(lang.hitch(this, function () {
        this.userGroup = this.store.get(userGroupId);

        if (!this.userGroup) {
          if (hash().match(/^admin/)) {
            hash('admin/users/UserGroupList');
          }
          else {
            hash('teacher/UserGroupList');
          }
          return;
        }

        this.userGroup.owner = 
        this.userStore.get(this.userGroup.owner).username;

        this.memberChooser.setData(array.map(this.userGroup.users, 
          lang.hitch(this, function (item) {
            return this.userStore.get(item);
          })
        ));

        this.setFormData(this.userGroup); 
      }));
    },

    submitCallback: function (data) {
      data.id = this.userGroup.id;
      data = this.mergeUserGroupData(data);

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iUsers.userGroupUpdatedAlert, data)
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

