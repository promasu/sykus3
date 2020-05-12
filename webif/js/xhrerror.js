define([
  'dojo/hash',
  './bootstrap',
  'mustache/mustache',
  'dojo/i18n!./common/nls/common'
], 
function(
  hash, bootstrap, mustache, iCommon
) {
  return function (error) {
    switch (error.response.status) {
      case 401: 
        if (!hash().match(/^session/)) {
          hash('session/Login!' + hash());
        }
        break;

      case 400:
        bootstrap.showAlert(
          'alert-danger',
          mustache.render(iCommon.alertHTTP400, { 
            message: error.response.data.replace(/^"|"$/g, '')
          })
        );
        break;

      default:
        bootstrap.showAlert('alert-danger', iCommon.alertHTTPUnknown);
        break;
    }
  };
});

