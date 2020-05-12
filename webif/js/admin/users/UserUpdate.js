define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/hash',
  'dojo/query',
  'dojo/on',
  './UserForm',
  '../../bootstrap',
  '../../nav',
  'mustache/mustache',
  '../../common/apiStore',
  '../../xhrerror',
  'dojo/text!./templates/UserUpdate.html',
  'dojo/text!./templates/UserForm.html',
  'dojo/text!../../common/templates/partialPopover.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
],
function (
  declare, lang, hash, query, on, UserForm, bootstrap, nav, mustache, apiStore,
  xhrerror, tUserUpdate, tUserForm, tPartialPopover, iUsers, iCommon
) {
  return declare([ UserForm ], {
    user: null,
    usernameChangeConfirmed: false,

    constructor: function (userId) {
      nav.set('admin', 'users', 'users');
      var store = apiStore('/api/users/');

      this.template = mustache.render(tUserUpdate, {
        iCommon: iCommon,
        iUsers: iUsers
      }, {
        UserForm: tUserForm
      });

      this.inherited(arguments);

      apiStore.allReady().then(lang.hitch(this, function () {
        this.user = store.get(userId);

        if (!this.user) {
          hash('admin/users/UserList');
          return;
        }

        if (this.user.user_class) {
          this.user.user_class = 
          this.classStore.get(this.user.user_class).name; 
        }

        this.setFormData(this.user);
        this.setRadio('position', this.user.position_group);
        this.setRadio('admin', this.user.admin_group); 

        this.setOpacityOption();
      }));
    },

    confirmUsernameChange: function (data) {
      var target, cb, template;

      if (this.user.username !== this.usernameHint &&
      this.usernameChangeConfirmed !== this.usernameHint) {
        template = mustache.render(tPartialPopover, {
          newName: this.usernameHint,
          oldName: this.user.username
        }, {
          popoverTitle: iUsers.usernameChange,
          popoverText: iUsers.usernameChangeText,
          popoverButton: iUsers.usernameChangeButton
        });

        target = bootstrap.showPopover(
          template, 
          query('.js-btn-submit', 'main')[0], 
          'right'
        );

        cb = lang.hitch(this, function () {
          this.usernameChangeConfirmed = this.usernameHint;
          this.submitCallback(data);
        });
        on(query('.js-btn-confirm', target), 'click', cb);
        return false;
      }
      return true;
    },

    submitCallback: function (data) {
      if (!this.confirmUsernameChange(data) ||
      !this.confirmAdmin(data, this.user.admin_group)) {
        return;
      }

      if ((this.usernameHint !== this.user.username) &&
      !this.confirmDuplicate(data)) {
        return;
      }

      data.id = this.user.id;
      data = this.mergeUserData(data);

      this.store.put(data).then(function () {
        bootstrap.showAlert(
          'alert-success', 
          mustache.render(iUsers.userUpdatedAlert, data)
        );

        hash('admin/users/UserList');
      }, xhrerror);
    },

    destroy: function () {
    }
  });
});
