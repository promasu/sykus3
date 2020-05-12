define([

],
function () {
  return function () {
    var lightdm = window.lightdm;

    window.show_prompt = function () {
      var data = {
        user: {
          username: 'localuser'
        }
      };

      lightdm.provide_secret(JSON.stringify(data)); 
    };

    window.authentication_complete = function () {
      if (lightdm.is_authenticated) {
        lightdm.login('localuser', lightdm.default_session);
      }
    };

    lightdm.start_authentication('localuser');
  };
});

