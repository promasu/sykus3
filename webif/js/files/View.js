define([
  'dojo/_base/declare',
  'dojo/_base/array',
  'dojo/dom-construct',
  'dojo/request',
  'dojo/hash',
  'dojo/query',
  'dojo/_base/lang',
  '../nav',
  '../xhrerror',
  '../common/dateDiff',
  '../session/identity',
  'mustache/mustache',
  'dojo/text!./templates/View.html',
  'dojo/text!./templates/ViewEntry.html',
  'dojo/text!./templates/ViewNoEntries.html',
  'dojo/i18n!./nls/common'
], 
function (
  declare, array, domConstruct, request, hash, query, lang, nav, xhrerror,
  dateDiff, identity, mustache, tView, tViewEntry, tViewNoEntries, iView
) {
  return declare(null, {
    constructor: function (args) {
      this.path = args;
      this.setPath();

      this.interval = setInterval(lang.hitch(this, this.update), 3000);
      this.update();
    },

    setPath: function () {
      var i, baseDirName, dirs, tcView, paths = [];

      if (!this.path.match(/\.$/)) {
        this.path += '/';
      }

      dirs = this.path.split('/');

      switch (dirs[0]) {
        case 'home':
          baseDirName = iView.basedirHome;
          break;
        case 'teacher':
          baseDirName = iView.basedirTeacher;
          break;
        case 'admin':
          baseDirName = iView.basedirAdmin;
          break;
        case 'progdata':
          baseDirName = iView.basedirProgdata;
          break;
        case 'groups':
          baseDirName = iView.basedirGroups;
          break;

        default: throw false;
      }

      for (i = 0; i < dirs.length - 1; i += 1) {
        paths.push({
          name: (i === 0) ? baseDirName : dirs[i], 
          path: dirs.slice(0, i + 1).join('/')
        });
      }

      tcView = mustache.render(tView, {
        iView: iView,
        paths: paths
      });

      nav.set('user', 'files', dirs[0]);
      domConstruct.place(tcView, 'main', 'only');

      query('.js-nav-submodule[data-id="teacher"]').addClass('hide');
      query('.js-nav-submodule[data-id="admin"]').addClass('hide');

      if (identity.permission('share_teacher_access')) {
        query('.js-nav-submodule[data-id="teacher"]').
        removeClass('hide');
      }

      if (identity.permission('share_admin_access')) {
        query('.js-nav-submodule[data-id="admin"]').
        removeClass('hide');
      }
    },

    update: function () {
      var url = '/api/files/' + this.path;
      var path = this.path;

      request.get(url, { handleAs: 'json' }).
      then(lang.hitch(this, function (res) {
        var tcViewEntry, tcViewNoEntries;
        var pathSplit = this.path.split('/');
        var tbody = domConstruct.create('tbody');

        if (pathSplit.length > 2) {
          res.unshift({
            name: '..',
            dir: true,
            full_path: pathSplit.slice(0, pathSplit.length - 2).join('/')
          });
        }

        array.forEach(res, function (entry) {
          var sizePrefix = 'B';

          entry.full_path = entry.full_path || (path + entry.name);

          if (entry.size > 1024) {
            entry.size /= 1024.0;
            sizePrefix = 'KB';
          }

          if (entry.size > 1024) {
            entry.size /= 1024.0;
            sizePrefix = 'MB';
          }

          entry.size = Math.ceil(entry.size) + ' ' + sizePrefix;
          entry.dateDiff = entry.mtime ? dateDiff(entry.mtime) : '';

          tcViewEntry = mustache.render(tViewEntry, entry);
          domConstruct.place(tcViewEntry, tbody, 'last');
        });

        if (res.length === 0 || (res.length === 1 && res[0].name === '..')) {
          tcViewNoEntries = mustache.render(tViewNoEntries, { iView: iView });
          domConstruct.place(tcViewNoEntries, tbody, 'last');
        }

        domConstruct.place(tbody, query('#FileViewMain tbody')[0], 'replace');
      }), function (error) {
        switch (error.response.status) {
          case 400:
          case 404:
            // redirect to home root on error
            hash('files/View!home');
            return;

          default:
            xhrerror(error);
            return;
        }
      });
    },

    destroy: function () { 
      clearInterval(this.interval);
    } 
  });

});

