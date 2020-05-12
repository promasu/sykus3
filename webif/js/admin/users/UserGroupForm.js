define([
  'dojo/_base/declare',
  'dojo/query',
  '../../common/apiStore',
  '../../common/Form',
  '../../common/Chooser',
  '../../common/MultiChooser',
  '../../common/ChooserConfigUser',
  '../../session/identity',
  'dojo/i18n!./nls/common'
], 
function (
  declare, query, apiStore, Form, Chooser, MultiChooser, ChooserConfigUser,
  identity, iUsers
) {
  return declare([ Form ], {
    constructor: function () {
      var OwnerChooser, MemberChooser;

      identity.enforcePermission('user_groups_write_own');

      this.inherited(arguments);

      this.store = apiStore('/api/usergroups/');
      this.userStore = apiStore('/api/users/');

      if (!identity.permission('user_groups_write')) {
        query('[data-field="owner"]').forEach(function (e) {
          e.value = identity.getUser().username;
          e.disabled = true;
        });
      }

      OwnerChooser = declare([ ChooserConfigUser, Chooser ], {});
      MemberChooser = declare([ ChooserConfigUser, MultiChooser ], {});

      this.ownerChooser = new OwnerChooser(
        query('[data-field="owner"]')[0],
        query('.js-dropdown-owner')[0]
      );

      this.memberChooser = new MemberChooser(
        query('[data-field="member-chooser"]')[0],
        query('.js-dropdown-member-chooser')[0],
        query('.js-member-list')[0]
      );
    },

    validateCallback: function (field) { 
      switch (field) {
        case 'name':
          return (this.getField(field).value.length > 2) ? 
          true: iUsers.validateUserGroupName;
        case 'owner':
          return this.userStore.query({ 
            username: this.getField(field).value 
          }).length === 1 ? true: iUsers.validateUserGroupOwner;
      }
      throw false;
    },

    mergeUserGroupData: function (data) {
      data.owner = this.userStore.query({ username: data.owner })[0].id;
      data.users = this.memberChooser.getMemberIdArray();
      return data;
    }
  });
});

