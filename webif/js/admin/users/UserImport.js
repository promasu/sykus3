define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/request',
  'dojo/query',
  'dojo/on',
  '../../common/Form',
  '../../bootstrap',
  '../../nav',
  '../../session/identity',
  '../../xhrerror',
  'mustache/mustache',
  'dojo/text!./templates/UserImport.html',
  'dojo/text!./templates/UserImportEntry.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!../../common/nls/grid'
], 
function (
  declare, lang, request, query, on, Form, bootstrap, nav, identity,
  xhrerror, mustache, tUserImport, tUserImportEntry, iUsers, iCommon
) {

  return declare([ Form ], {
    confirmStage: false,

    constructor: function () {
      nav.set('admin', 'users', 'userimport');
      this.template = mustache.render(tUserImport, {
        iCommon: iCommon,
        iUsers: iUsers
      });

      this.inherited(arguments);

      on(
        query('[data-field="position"]', 'main'), 
        'change', 
        lang.hitch(this, this.updateDataHelp)
      );
      this.updateDataHelp();

      on(
        query('.js-btn-cancel', 'main'), 
        'click', 
        lang.hitch(this, this.resetStage)
      );

      if (identity.permission('users_import')) {
        query('.js-btn-check').removeClass('hide');
      }
    },

    updateDataHelp: function () {
      var str; 

      switch (this.getRadio('position')) {
        case 'student':
          str = iUsers.importDataTextStudent;
          break;

        case 'teacher':
          str = iUsers.importDataTextTeacher;
          break;

        default: return;
      }

      query('.js-data-help')[0].innerHTML = str;

    },

    updateStage: function () {
      if (this.confirmStage) {
        query('.js-results').removeClass('hide');
        query('.js-input-stage').addClass('hide');
      }
      else {
        query('.js-results').addClass('hide');
        query('.js-input-stage').removeClass('hide');
        query('.js-btn-confirm').removeClass('hide');
      }
    },

    resetStage: function () {
      this.confirmStage = false;
      this.updateStage();

      if (this.resetFormOnBack) {
        this.resetFormOnBack = false;
        query('form', 'main')[0].reset();
      }
    },

    getAction: function (action) {
      switch (action) {
        case 'new': 
          return { 
            title: iUsers.importActionNewTitle,
            text: iUsers.importActionNewText,
            label: 'label-success'
          };
        case 'updated':
          return { 
            title: iUsers.importActionUpdatedTitle,
            text: iUsers.importActionUpdatedText,
            label: 'label-warning'
          };

        case 'deleted':
          return { 
            title: iUsers.importActionDeletedTitle,
            text: iUsers.importActionDeletedText,
            label: 'label-danger'
          };
      }
      throw false;
    },

    submitCallback: function () {
      var req, data;

      data = {
        type: this.getRadio('position'),
        'delete': (this.getRadio('delete') === 'true'),
        confirm: this.confirmStage,
        data: this.getField('data').value
      };

      if (data.type === 'student') {
        query('.js-user-class-title').removeClass('hide');
      }
      else {
        query('.js-user-class-title').addClass('hide');
      }

      if (data.confirm) {
        this.resetFormOnBack = true;
        query('.js-btn-confirm').addClass('hide');
      }

      req = {
        data: JSON.stringify(data),
        handleAs: 'json'
      };

      request.post('/api/userimport/', req).then(
        lang.hitch(this, function (res) {
          var rows = [];

          res.result.forEach(lang.hitch(this, function (row) {
            rows.push(mustache.render(tUserImportEntry, { 
              data: row,
              action: this.getAction(row.status)
            }));
          }));

          query('.js-results tbody')[0].innerHTML = rows.join('');

          this.confirmStage = true;
          this.updateStage();

          if (data.confirm) {
            bootstrap.showAlert('alert-success', iUsers.importAlert);
          }

        }), xhrerror);
    },

    destroy: function () {
    }
  });
});

