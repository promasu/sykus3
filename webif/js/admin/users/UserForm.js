define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/on',
  'dojo/query',
  'dojo/store/JsonRest',
  'dojo/date/locale',
  'mustache/mustache',
  '../../bootstrap',
  '../../common/apiStore',
  '../../common/Form',
  '../../common/Chooser',
  '../../common/ChooserConfigUserClass',
  '../../session/identity',
  'dojo/i18n!./nls/common',
  'dojo/text!../../common/templates/partialPopover.html'
],
function (
  declare, lang, on, query, JsonRest, dateLocale,
  mustache, bootstrap, apiStore, Form, Chooser, ChooserConfigUserClass,
  identity, iUsers, tPartialPopover
) {
  return declare([ Form ], {
    usernameHint: null,
    usernameStore: null,
    duplicateConfirmed: false,
    adminConfirmed: false,
    confirmedUsername: false,

    constructor: function () {
      var ClassChooser;

      identity.enforcePermission('users_write');

      this.inherited(arguments);

      this.usernameStore = new JsonRest({ target: '/api/users/username/' });
      this.store = apiStore('/api/users/');
      this.classStore = apiStore('/api/userclasses/');

      on(
        query('[data-field="first_name"], [data-field="last_name"]'),
        'change',
        lang.hitch(this, this.updateUsername)
      );

      if (!identity.permission('users_write_admin')) {
        query('[data-field="admin"]').forEach(function (e) {
          e.disabled = true;
        });
      }

      ClassChooser = declare([ ChooserConfigUserClass, Chooser ], {});

      this.classChooser = new ClassChooser(
        query('[data-field="user_class"]')[0],
        query('.js-dropdown-user-class')[0]
      );
    },

    validateCallback: function (field) { 
      var res;

      switch (field) {
        case 'first_name': 
        case 'last_name':
          if (this.usernameHint === null) {
            return iUsers.validateFullName;
          }
          return true;

        case 'birthdate':
          res = dateLocale.parse(this.getField(field).value, {
            selector: 'date',
            datePattern: 'dd.MM.yyyy'
          });
          return res ? true : iUsers.validateBirthdate;

        case 'user_class':
          if (this.getRadio('position') !== 'student') {
            return true;
          }
          return this.getField(field).value !== '' ? 
          true : iUsers.validateUserClass;

      }
      throw false;
    },

    updateUsername: function() {
      this.confirmedUsername = false;

      return this.usernameStore.put({
        'ref_id': this.user ? this.user.id : null,
        'first_name': this.getField('first_name').value,
        'last_name': this.getField('last_name').value
      }).then(lang.hitch(this, function (result) {
        this.usernameHint = result.username || null;
        this.getField('username').value = this.usernameHint || '';

        this.validateField(this.getField('first_name'));
      }));
    },

    mergeUserData: function (data) {
      var user_class;

      data.username = this.usernameHint;
      data.position_group = this.getRadio('position');
      data.admin_group = this.getRadio('admin');

      user_class = this.classStore.query({ 
        name: this.getField('user_class').value 
      });
      data.user_class = user_class[0] ? user_class[0].id : null;
      return data;
    },

    submit: function () {
      if (!this.confirmedUsername) {
        this.updateUsername().then(lang.hitch(this, function () {
          this.confirmedUsername = true;
          this.submit();
        }));
      }
      else {
        return this.inherited(arguments);
      }
    },

    confirmAdmin: function (data, ref) {
      var template, target, cb;

      if (this.getRadio('admin') !== ref && !this.adminConfirmed) {
        template = mustache.render(tPartialPopover, {}, {
          popoverTitle: iUsers.adminConfirmTitle,
          popoverText: iUsers.adminConfirmText,
          popoverButton: iUsers.adminConfirmButton
        });

        target = bootstrap.showPopover(
          template, 
          query('.js-btn-submit', 'main')[0], 
          'right'
        );

        cb = lang.hitch(this, function () {
          this.adminConfirmed = true;
          this.submitCallback(data);
        });
        on(query('.js-btn-confirm', target), 'click', cb);
        return false;
      }
      return true;
    },

    confirmDuplicate: function (data) {
      var template, target, cb, username = this.usernameHint;

      if (username.match(/\d$/) && !this.duplicateConfirmed) {
        template = mustache.render(tPartialPopover, {
          username: username,
          basename: username.replace(/\d/g, '')
        }, {
          popoverTitle: iUsers.duplicateUsername,
          popoverText: iUsers.duplicateUsernameText,
          popoverButton: iUsers.duplicateUsernameButton
        });

        target = bootstrap.showPopover(
          template, 
          query('.js-btn-submit', 'main')[0], 
          'right'
        );

        cb = lang.hitch(this, function () {
          this.duplicateConfirmed = true;
          this.submitCallback(data);
        });
        on(query('.js-btn-confirm', target), 'click', cb);
        return false;
      }
      return true;
    }

  });
});
