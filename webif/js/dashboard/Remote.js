define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/dom-construct',
  'dojo/query',
  'dojo/on',
  '../nav',
  '../config',
  '../session/identity',
  'mustache/mustache',
  'dojo/text!./templates/Remote.html',
  'dojo/i18n!./nls/common',
  'dojo/i18n!./nls/remote'
], 
function (
  declare, lang, domConstruct, query, on, nav, config, identity,
  mustache, tRemote, iDashboard, iRemote
) {
  return declare(null, {
    constructor: function () {
      var tcRemote;
      nav.set('user', 'dashboard', 'remote');

      tcRemote = mustache.render(tRemote, {
        student: (identity.getUser().position_group === 'student'),
        webifUrl: 'https://' + window.document.domain,
        iDashboard: iDashboard,
        iRemote: iRemote
      });

      domConstruct.place(tcRemote, 'main', 'only');

      on(query('.js-webif-url'), 'click', function () {
        var e = query('.js-webif-url')[0];
        e.value = e.defaultValue;
        e.select();
      });

      on(
        query('.js-input-files'),
        'click', 
        lang.hitch(this, function (ev) {
          this.updateFiles();
          ev.target.select();
        })
      );

      on(
        query('.js-select-files-how'),
        'change', 
        lang.hitch(this, this.updateFiles)
      );

      this.initFiles();
    },

    initFiles: function () {
      var how, agent = window.navigator.userAgent;

      if (agent.match(/Linux/i)) {
        how = 'linux';
      }
      else if (agent.match(/Mac OS/i)) {
        how = 'mac';
      }
      else {
        how = 'win';
      }

      query('.js-select-files-how').val(how);
      this.updateFiles();
    },

    updateFiles: function () {
      var url, domain = window.document.domain;

      switch (query('.js-select-files-how')[0].value) {
        case 'win':
        case 'mac':
          url = 'https://' + domain + '/dav/';
          break;

        case 'linux':
          url = 'davs://' + domain + '/dav/';
          break;
      }
      query('.js-input-files').val(url);
    },

    destroy: function () {
      clearInterval(this.interval);
    }
  });

});

