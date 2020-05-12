define([
  'dojo/_base/declare',
  'dojo/dom-construct',
  'dojo/request',
  'dojo/on',
  'dojo/query',
  'dojo/_base/lang',
  'dojo/dom-class',
  '../nav',
  '../bootstrap',
  '../config',
  '../common/apiStore',
  'mustache/mustache',
  'dojo/text!./templates/RoomCtl.html',
  'dojo/text!./templates/RoomCtlEntry.html',
  'dojo/text!./templates/RoomCtlChooser.html',
  'dojo/text!./templates/RoomCtlNoScreens.html',
  'dojo/text!./templates/RoomCtlExternal.html',
  'dojo/i18n!../common/nls/common',
  'dojo/i18n!./nls/roomctl'
], 
function (
  declare, domConstruct, request, on, query, lang, domClass, nav, bootstrap,
  config, apiStore, mustache, tRoomCtl, tRoomCtlEntry, tRoomCtlChooser,
  tRoomCtlNoScreens, tExternal, iCommon, iRoomCtl
) {
  var setLockInterval = null;

  return declare(null, {
    constructor: function () {
      var tcRoomCtl, tcExternal;

      this.host_group = config.get('host_group');

      this.hostGroupStore = apiStore('/api/hostgroups/');

      tcRoomCtl = mustache.render(tRoomCtl, {
        iRoomCtl: iRoomCtl 
      });

      nav.set('user', 'teacher', 'roomctl');
      domConstruct.place(tcRoomCtl, 'main', 'only');

      if (!config.get('net_int')) {
        tcExternal = mustache.render(tExternal, {
          iRoomCtl: iRoomCtl
        });

        domConstruct.place(tcExternal, query('#RoomCtlMain .row')[0], 'only');
        return;
      }

      this.interval = setInterval(lang.hitch(this, this.update), 2500);

      // global interval to keep state even if user selects different tab
      if (!setLockInterval) {
        setLockInterval = 
        setInterval(lang.hitch(this, this.setLockState), 5000);
      }

      this.addBtnHook('screenlock');
      this.addBtnHook('weblock');
      this.addBtnHook('printerlock');
      this.addBtnHook('soundlock');

      on(
        query('.js-btn-choose'), 
        'click', 
        lang.hitch(this, this.selectHgPopover)
      );

      if (!this.host_group) {
        apiStore.allReady().then(lang.hitch(this, this.selectHgPopover));
      }

      this.update();
      return;
    },

    selectHgPopover: function () {
      var template, node, ref;

      template = mustache.render(tRoomCtlChooser, {
        iRoomCtl: iRoomCtl,
        iCommon: iCommon,
        hostGroups: this.hostGroupStore.query({})
      });

      ref = query('.js-btn-choose')[0];
      node = bootstrap.showPopover(template, ref, 'left');

      on(query('select', node), 'change', lang.hitch(this, this.selectHg));
    },

    selectHg: function () {
      var hgName, node = query('.js-chooser option:checked')[0];
      this.host_group = +node.dataset.id;
      hgName = this.hostGroupStore.get(this.host_group).name;

      bootstrap.clearPopover();
      query('.js-btn-choose').text(iRoomCtl.changeHgPrefix + hgName);

      this.update();
    },

    addBtnHook: function (what) {
      on(
        query('.js-btn-' + what), 
        'click', 
        lang.hitch(this, lang.partial(this.setLockState, what))
      );
    },

    update: function () {
      if (!this.host_group) {
        return;
      }
      var url = '/api/roomctl/' + this.host_group;
      request.get(url, { handleAs: 'json' }).
      then(lang.hitch(this, function (res) {
        this.state = res;
        this.updateScreens();
        this.updateButtons();
      }));
    },

    updateScreens: function () {
      var domList, tcRoomctlNoScreens;

      if (this.old_screens !== JSON.stringify(this.state.screens)) {
        this.old_screens = JSON.stringify(this.state.screens);

        domList = query('.js-list')[0];
        domConstruct.empty(domList);

        this.state.screens.forEach(lang.hitch(this, function (screen) {
          var template = mustache.render(tRoomCtlEntry, { data: screen });
          domConstruct.place(template, domList, 'last');
        }));

        query('> div', domList).forEach( lang.hitch(this, function (element) {
          on(element, 'click', lang.partial(this.enlargeScreen, element));
        }));

        if (this.state.screens.length === 0) {
          tcRoomctlNoScreens = mustache.render(tRoomCtlNoScreens, {
            iRoomCtl: iRoomCtl
          });
          domConstruct.place(tcRoomctlNoScreens, domList, 'only');
        }
      }

      query('.js-roomctl-img').forEach(function (img) {
        img.title = iRoomCtl.screenImageTitle;
        img.src = img.src.split('?')[0] + '?' + (new Date()).getTime();
      });
    },

    enlargeScreen: function (element) {
      var same, enlargeClasses = 'force-full-width js-enlarge';

      same = domClass.contains(element, 'js-enlarge');

      query('.js-list > div').forEach(function (e) {
        domClass.remove(e, enlargeClasses);
      });

      if (!same) {
        domClass.add(element, enlargeClasses);
        element.scrollIntoView();
      }
    },

    updateButtons: function () {
      var classBoth = 'btn-success btn-danger hide', 
      classGreen = 'btn-success',
      classRed = 'btn-danger';

      query('.js-btn-weblock').text(this.state.weblock ? 
        iRoomCtl.btnWeblockTrue : iRoomCtl.btnWeblockFalse
      ).removeClass(classBoth).addClass(
        this.state.weblock ? classRed : classGreen
      );

      query('.js-btn-printerlock').text(this.state.printerlock ? 
        iRoomCtl.btnPrinterlockTrue : iRoomCtl.btnPrinterlockFalse
      ).removeClass(classBoth).addClass(
        this.state.printerlock ? classRed : classGreen
      );

      query('.js-btn-screenlock').text(this.state.screenlock ? 
        iRoomCtl.btnScreenlockTrue : iRoomCtl.btnScreenlockFalse
      ).removeClass(classBoth).addClass(
        this.state.screenlock ? classRed : classGreen
      );

      query('.js-btn-soundlock').text(this.state.soundlock ? 
        iRoomCtl.btnSoundlockTrue : iRoomCtl.btnSoundlockFalse
      ).removeClass(classBoth).addClass(
        this.state.soundlock ? classRed : classGreen
      );
    },

    setLockState: function (what) {
      var req;

      if (what) {
        this.state[what] = !this.state[what];
      }

      if (!this.host_group) {
        return;
      }

      req = request.post('/api/roomctl/' + this.host_group, { 
        data: JSON.stringify({
          screenlock: this.state.screenlock,
          weblock: this.state.weblock,
          printerlock: this.state.printerlock,
          soundlock: this.state.soundlock
        }) 
      });

      if (what) {
        req.then(lang.hitch(this, this.update));
      }
    },

    destroy: function () { 
      clearInterval(this.interval);
    } 
  });

});

