define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  '../../nav',
  '../../common/apiStore',
  'mustache/mustache',
  'dojo/text!./templates/InitialPasswords.html',
  'dojo/text!./templates/InitialPasswordsList.html',
  'dojo/text!./templates/InitialPasswordsEntry.html',
  'dojo/text!./templates/InitialPasswordsCheckbox.html',
  'dojo/i18n!../../common/nls/common',
  'dojo/i18n!./nls/common'
], 
function (
  declare, domConstruct, on, query, lang, nav, apiStore, mustache, 
  tInitialPasswords, tInitialPasswordsList, tInitialPasswordsEntry, 
  tInitialPasswordsCheckbox, iCommon, iUsers
) {
  return declare(null, {
    constructor: function () {
      var tcInitialPasswords;

      tcInitialPasswords = mustache.render(tInitialPasswords, {
        iUsers: iUsers 
      });

      nav.set('admin', 'users', 'initialpasswords');
      domConstruct.place(tcInitialPasswords, 'main', 'only');

      this.userStore = apiStore('/api/users/');
      this.userClassStore = apiStore('/api/userclasses/');
      apiStore.allReady().then(lang.hitch(this, this.addCheckboxes));

      on(query('.js-print'), 'click', function () { 
        window.print();
      });

      on(
        query('.js-select-none'), 
        'click', 
        lang.hitch(this, lang.partial(this.selectCheckboxes, false))
      );

      on(
        query('.js-select-all'), 
        'click', 
        lang.hitch(this, lang.partial(this.selectCheckboxes, true))
      );
    },

    selectCheckboxes: function (selectFlag, e) {
      e.preventDefault();
      query('.js-class-select input').forEach(function (element) {
        element.checked = selectFlag;
      });
      this.update();
    },

    addCheckboxes: function () {
      var list, queryOpts = { 
        sort: [ { attribute: 'name' } ] 
      };

      list = query('.js-class-select')[0];

      this.userClasses = this.userClassStore.query({}, queryOpts);
      this.userClasses.unshift({ id: null, name: iUsers.positionTeacher });
      this.userClasses.forEach(function (cl) {
        var node, template;
        template = mustache.render(tInitialPasswordsCheckbox, { data: cl });
        node = domConstruct.place(template, list, 'last');
      });

      on(query('input', list), 'change', lang.hitch(this, this.update));

      this.update();
    },

    filterCallback: function (classId, user) {
      if (user.user_class !== classId) {
        return false;
      }

      if (user.position_group !== 'student') {
        return false;
      }

      if (!user.password_initial) {
        return false;
      }

      return true;
    },

    update: function () {
      var outputContainer = query('.js-output')[0];
      var queryOpts = { 
        sort: [ { attribute: 'username' } ] 
      };

      domConstruct.empty(outputContainer);

      this.userClasses.forEach(
        lang.hitch(this, function (cl) {
          var template, userList, nodeName;

          nodeName = 'input[data-class-id="' + (cl.id || '') + '"]';
          if (!query(nodeName)[0].checked) {
            return;
          }

          userList = this.userStore.query(
            lang.partial(this.filterCallback, cl.id), 
            queryOpts
          );

          if (userList.length === 0) {
            return;
          }

          template = mustache.render(tInitialPasswordsList, { data: cl });
          domConstruct.place(template, outputContainer, 'last');

          userList.forEach(function (user) {
            var outputList = query('ul', outputContainer).last()[0];

            if (!user.password_initial) {
              return; 
            }

            template = mustache.render(tInitialPasswordsEntry, { 
              user: user,
              userClass: cl,
              iCommon: iCommon,
              iUsers: iUsers
            });

            domConstruct.place(template, outputList, 'last');
          });
        })
      );
    },

    destroy: function () { } 
  });

});

