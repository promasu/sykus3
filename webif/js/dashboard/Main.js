define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/request',
  'dojo/query',
  'dojo/_base/lang',
  '../nav',
  '../config',
  '../session/identity',
  'mustache/mustache',
  'dojo/text!./templates/Main.html',
  'dojo/i18n!./nls/common'
], 
function (
  declare, domConstruct, request, query, lang, nav, config, identity,
  mustache, tMain, iDashboard
) {
  return declare(null, {
    constructor: function () {
      nav.set('user', 'dashboard', 'main');

      query('#main').empty();

      this.interval = setInterval(lang.hitch(this, this.update), 5000);
      this.update();
    },

    update: function () {
      request.get('/api/dashboards/user/', { 
        handleAs: 'json' 
      }).then(function (data) {
        var user, tcMain;
        var quotaClass, quotaPercent, quotaWarning = false;

        user = identity.getUser();
        quotaPercent = Math.ceil(data.quota_used * 100.0 / data.quota_total);

        quotaClass = '';
        if (quotaPercent > 70) {
          quotaWarning = true;
          quotaClass = 'progress-bar-warning';
        }
        if (quotaPercent > 90) {
          quotaClass = 'progess-bar-danger';
        }

        tcMain = mustache.render(tMain, {
          user: user,
          dashboard: data,
          quotaWarning: quotaWarning,
          quotaClass: quotaClass,
          quotaPercent: quotaPercent,
          iDashboard: iDashboard
        }, { 
          tplTitle: iDashboard.title,
          tplQuotaText: iDashboard.quotaText
        });

        domConstruct.place(tcMain, 'main', 'only');

        // REVIEW: remove
        if (config.get('demo')) {
          query('.js-demo').removeClass('hide');
        }

        if (config.get('net_cli') && 
        identity.permission('teacher_roomctl')) {
          query('.js-roomctl').removeClass('hide');
        }
      });
    },

    destroy: function () {
      clearInterval(this.interval);
    }
  });

});

