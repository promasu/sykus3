define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/on',
  'dojo/query',
  'dojo/dom-construct',
  'dojo/dom-class',
  '../bootstrap',
  'dojo/i18n!./nls/common'
], 
function (
  declare, lang, on, query, domConstruct, domClass, bootstrap, iCommon
) {
  return declare(null, {
    '-chains-': { constructor: 'manual' },
    template: null,

    constructor: function () {
      var that = this;

      domConstruct.place(this.template, 'main', 'only');

      query('.js-validate', 'main').forEach(function (field) {
        if (!query('.validate', field).length) {
          domConstruct.create('span', {
            className: 'validate'
          }, field, 'last');
        }

        on(
          query('[data-field]', field), 
          'change', 
          function () { that.validateField(this); }
        );
      });

      on(query('form', 'main'), 'submit', lang.hitch(this, function (e) {
        e.preventDefault();
        this.submit();
      }));

      this.initOpacityOption();

      if (query('.js-focus')[0]) {
        query('.js-focus')[0].focus();
      }
    },

    getField: function (fieldId) {
      return query('[data-field="' + fieldId + '"]', 'main')[0];
    },

    setFormData: function (data) {
      var field, node;
      for (field in data) {
        if (data.hasOwnProperty(field)) {
          node = query('[data-field="' + field + '"]', 'main');
          if (node && node[0]) {
            node[0].value = data[field] || '';
          }
        }
      }
    },

    initOpacityOption: function () {
      query('.js-opacity-option [type="radio"]').forEach(
        lang.hitch(this, function (e) {
          on(e, 'change', lang.hitch(this, this.setOpacityOption));
        })
      );
      this.setOpacityOption();
    },

    getRadio: function (field) {
      var value = null;
      query('[data-field="' + field + '"]').some(function (e) {
        if (e.checked) {
          value = e.value;
          return true;
        }
        return false;
      });
      return value;
    },

    setRadio: function (field, value) {
      value = value || '';
      query('[data-field="' + field + '"]').forEach(function (e) {
        e.checked = (e.value === value);
      });
    },

    setOpacityOption: function () {
      query('.js-opacity-option').forEach(lang.hitch(this, function (e) {
        var ob = query('[type="radio"]', e)[0];
        if (ob.checked) {
          domClass.remove(e, 'opaque');
        }
        else {
          domClass.add(e, 'opaque');
        }
      }));
    },

    validateField: function(field, showErrors) {
      var errorString, valid, validateLine, formGroup;

      errorString = this.validateCallback(field.dataset.field);
      valid = (errorString === true);

      if (!valid && !showErrors) {
        return false;
      }

      validateLine = (
        query('.validate', field.parentNode)[0] ||
        query('.validate', field.parentNode.parentNode)[0]
      );

      formGroup = field;
      while (!domClass.contains(formGroup, 'form-group')) {
        formGroup = formGroup.parentNode;
      }

      if (valid) {
        domClass.remove(formGroup, 'has-error');
        domClass.add(formGroup, 'has-success');
        domConstruct.empty(validateLine);
      }
      else {
        domClass.remove(formGroup, 'has-success');
        domClass.add(formGroup, 'has-error');

        domConstruct.create('i', { 
          className: 'icon-large icon-remove', 
          innerHTML: ' '
        }, validateLine, 'only');

        domConstruct.create('span', { 
          innerHTML: errorString
        }, validateLine, 'last');
      }

      return valid;
    },

    submit: function () {
      var valid = true, data = {};

      query('.js-validate [data-field]', 'main').forEach(
        lang.hitch(this, function (field) {
          if (this.validateField(field, true) !== true) {
            valid = false;
          }
          if (field.value.length > 0) {
            data[field.dataset.field] = field.value;
          }
        })
      );
      if (valid) {
        this.submitCallback(data);
      }
      else {
        bootstrap.showAlert('alert-danger', iCommon.formInvalidData);
      }
    },

    validateCallback: function () { throw 'Not implemented'; },
    submitCallback: function () { throw 'Not implemented'; }
  });
});

