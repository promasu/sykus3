define([
  'dojo/query',
  './session/identity'
],
function (
  query, identity
) {
  return {
    set: function (panel, module, subModule) {
      var user = identity.getUser();

      query('.js-nav-panel, .js-nav-module-list').addClass('hide');
      query('.js-nav-module, .js-nav-submodule').removeClass('active');

      query('.js-nav-panel[data-id="' + panel + 
        '"]').removeClass('hide');
      query('.js-nav-module-list[data-id="' + 
        module + '"]').removeClass('hide');
      query('.js-nav-module[data-id="' + module + '"]').addClass('active');
      query('.js-nav-submodule[data-id="' + 
        subModule + '"]').addClass('active');

      query('.js-nav-module[data-id="teacher"]').addClass('hide');
      query('.js-nav-module[data-id="admin"]').addClass('hide');

      // below are some simplified assumptions about permissions
      // be sure to change them if you edit server/lib/config/permissions.rb
      if (user) {
        if (
          user.position_group === 'teacher' ||
          user.admin_group === 'senior' ||
          user.admin_group === 'super'
        ) {
          query('.js-nav-module[data-id="teacher"]').removeClass('hide');
        }

        if (user.admin_group !== 'none') {
          query('.js-nav-module[data-id="admin"]').removeClass('hide');
        }
      }
    }
  };
});

