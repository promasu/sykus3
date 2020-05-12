define([
  'dojo/request',
  'dojo/query',
  'dojo/on',
  './xhrerror',
  'dojo/i18n!./common/nls/common'
], 
function (
  request, query, on, xhrerror, iCommon
) {
  var config, demoHooksApplied = false;

  function demoHooks() {
    query('.js-demo').removeClass('hide');

    on(query('.js-school-name'), 'click', function () {
      if (window.confirm(iCommon.demoResetText)) {
        request.post('/api/demodata/');
      }
    });
  }

  function hooks() {
    query('.js-school-name').text(config.school_name);

    if (config.demo && !demoHooksApplied) {
      demoHooks();
      demoHooksApplied = true;
    }
  }

  return {
    get: function (name) {
      return config[name];
    },

    refresh: function () {
      var req = request.get('/api/config/public/', { handleAs: 'json' });

      return req.then(function (res) {
        config = res;
        hooks();
      }, xhrerror);
    }
  };
});

