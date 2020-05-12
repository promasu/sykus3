define([
  'dojo/_base/declare',
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
  'dojo/text!./templates/UserClasses.html',
  'dojo/text!./templates/UserClassesEntry.html',
  'dojo/text!./templates/UserClassesCreate.html',
  'dojo/text!../../common/templates/gridFilter.html',
  'dojo/text!../../common/templates/partialPopover.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, domConstruct, on, query, lang, Grid, apiStore, mustache, bootstrap, 
  nav, xhrerror, identity, tUserClasses, tUserClassesEntry, tUserClassesCreate, 
  tGridFilter, tPartialPopover, iUsers, iCommon, iGrid
) {
  return declare([ Grid ], {
    api: '/api/userclasses/',
    domTable: 'UserClassesTable',
    tRow: tUserClassesEntry,

    constructor: function () {
      var tcUserClasses;

      nav.set('admin', 'users', 'userclasses');

      identity.enforcePermission('user_classes_read');

      this.usersStore = apiStore('/api/users/');

      tcUserClasses = mustache.render(tUserClasses, {
        iCommon: iCommon,
        iGrid: iGrid,
        iUsers: iUsers
      }, {
        gridFilter: tGridFilter
      });
      domConstruct.place(tcUserClasses, 'main', 'only');

      if (identity.permission('user_classes_write')) {
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

      if (!identity.permission('user_classes_write')) {
        return;
      }

      if (this.usersStore.query({ user_class: rowId }).length) {
        bootstrap.showAlert('alert-danger', iUsers.userClassDeleteEmptyAlert);
        return;
      }

      template = mustache.render(tPartialPopover, {
        data: this.store.get(rowId), 
        popoverButtonClass: 'btn-danger'
      }, {
        popoverTitle: iUsers.deleteUserClass,
        popoverText: iUsers.userClassDeleteText,
        popoverButton: iUsers.userClassDeleteButton
      });

      ref = query(':first-child', rowNode)[0];
      node = bootstrap.showPopover(template, ref, 'right');

      on(
        query('.btn', node), 
        'click', 
        lang.hitch(this, lang.partial(this.deleteClass, rowId))
      );
    },

    deleteClass: function (id) {
      this.store.remove(id).then(function () {
        bootstrap.showAlert('alert-success', iUsers.userClassDeletedAlert);
      }, xhrerror);
    },

    compileData: function (data) {
      data.users = this.usersStore.query({ 
        user_class: data.id 
      }, {
        sort: [ { attribute: 'username' } ]
      }).map(function (user) {
        return user.first_name + ' ' + user.last_name;
      }).join(', ');

      return this.inherited(arguments);
    },

    createPopover: function () {
      var template, node, ref;

      ref = query('.js-btn-create')[0];
      template = mustache.render(tUserClassesCreate, {
        iUsers: iUsers,
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
          mustache.render(iUsers.createUserClassAlert)
        );
      }), xhrerror);
    },

    destroy: function () {
      this.inherited(arguments);
    }
  });
});
