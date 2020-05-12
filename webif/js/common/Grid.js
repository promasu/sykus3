define([
  'dojo/_base/declare',
  'dojo/_base/lang',
  'dojo/_base/array',
  'dojo/on',
  'dojo/query',
  'dojo/dom-construct',
  'dojo/dom-class',
  './apiStore',
  'mustache/mustache',
  'dojo/_base/window',
  'dojo/dom-geometry'
], 
function (
  declare, lang, array, on, query, domConstruct, domClass,
  apiStore, mustache, winBase, domGeometry
) {

  /**
  * Grid class which creates a dynamic data grid, backed up by a 
  * RESTful API store.
  *
  * Must be given a DOMNode which contains the following:
  *
  * * `thead` with `th` Tags (for sort hook insertion)
  *   * `th` tags need a `data-sort-field` attribute containing
  *     the field id for sorting (optional).
  * * `input` tag with `js-filter-input` class which is then hooked up 
  *   to the auto-filter mechanism (optional).
  *  
  * @class Grid
  * @module Common
  * @constructor
  */
  return declare(null, {
    '-chains-': { constructor: 'manual' },

    defaultMaxItems: 20,
    animDuration: 350,

    idToDom: {},
    observer: null,
    sortFieldId: null,
    sortDesc: false,
    maxItems: null,
    filterString: '',
    scrolledAllItems: false,
    scrollTimer: false,

    /**
    * @method constructor 
    * @param this {Object} Expects the following in instance object:
    * @param this.api {String} Store API target.
    * @param this.domTable {DOMNode} Node which contains the Grid layout.
    * @param this.tRow {Template} Template containing one grid row.
    *   Must not contain `tr` tags.
    * @param this.rowClickCallback {Function} Gets called when a row is 
    *   clicked (optional).
    * */
    constructor: function () {
      this.store = apiStore(this.api);
      this.domTBody = query('tbody', this.domTable)[0];
      this.domNothingFound = query('tfoot', this.domTable);
      this.tcRow = mustache.compile(this.tRow);

      this.addSortHooks();
      this.addFilterHook();

      // wait for initial data to be loaded.
      // this is not required but has less overhead and
      // prevents "new row" animations.
      apiStore.allReady().then(lang.hitch(this, function () {
        this.update(true);
        this.scroll();

        this.scrollEvent = 
        on(winBase.doc, 'scroll', lang.hitch(this, this.scroll));
      }));
    },

    /**
    * Use asynchronous calling to ensure document geometry
    * gets updated and to prevent short-circuits.
    * @method scroll
    * */
    scroll: function () {
      if (!this.scrollTimer) {
        this.scrollTimer = true; 
        setTimeout(lang.hitch(this, this.scrollAction), 150);
      }
    },

    /**
    * Implements infinite scroll mechanism.
    * Checks if there is enough document left "below" the viewport.
    * If there is not, it increases the displayed item count and updates
    * the grid.
    * @method scrollAction
    * @private
    * */
    scrollAction: function () {
      var distanceToEnd, bodyNode, htmlPos, tablePos, scrollTop;

      this.scrollTimer = false;

      bodyNode = query('body')[0];
      scrollTop = bodyNode.scrollTop || query('html')[0].scrollTop;

      htmlPos = domGeometry.position(bodyNode, false);
      tablePos = domGeometry.position(this.domTBody, false);

      distanceToEnd = tablePos.h - scrollTop - htmlPos.h;

      if (distanceToEnd < 200 && !this.scrolledAllItems) {
        this.maxItems += 20;
        this.update();
      }
    },

    /**
    * Cancels all polling and updating to the grid so
    * that it can be safely removed from DOM.
    * @method destroy
    * */
    destroy: function () {
      if (this.scrollEvent) {
        this.scrollEvent.remove();
      }
      if (this.observer) {
        this.observer.cancel();
      }
    }, 

    /**
    * Performs a search programatically
    * @method setSearch
    * @private
    * */
    setSearch: function (value) {
      query('input.js-filter-input', this.domTable).val(value);
      this.filterString = value;
      this.update(true);
    },

    /**
    * Adds the update hook to the filter input.
    * @method addFilterHook
    * @private
    * */
    addFilterHook: function () {
      var filterInput = query('input.js-filter-input', this.domTable);

      on(filterInput, 'keyup', lang.hitch(this, function () {
        this.filterString = filterInput[0].value;
        this.update(true);
      }));

      if (filterInput[0]) {
        filterInput[0].focus();
      }
    },

    /**
    * Injects sort icons and sort-hooks into all 
    * `th` Tags which have a fieldId property
    * @method addSortHooks
    * @private
    * */
    addSortHooks: function () {
      query('thead th[data-sort-field]', this.domTable).forEach(
        lang.hitch(this, function (heading) {
          var sortIcon, fieldId;

          sortIcon = domConstruct.create('i', {
            // dummy icon for proper spacing
            className: 'icon-caret-up'
          }, heading, 'last');

          fieldId = heading.dataset.sortField;

          // default sorting
          this.sortFieldId = this.sortFieldId || fieldId;
          if (this.sortFieldId === fieldId) {
            domClass.replace(sortIcon, 'visible ' + 
              (this.sortDesc ? 'icon-caret-down' : 'icon-caret-up'));
          }

          on(heading, 'click', lang.hitch(this, 
            lang.partial(this.setSort, fieldId, sortIcon)));
        }));
    },

    /**
    * Sets the current sort field and direction.
    * @method setSort
    * @private
    * */
    setSort: function (fieldId, sortIcon) {
      this.sortDesc = !this.sortDesc;
      if (this.sortFieldId !== fieldId) {
        this.sortDesc = false;
      }
      this.sortFieldId = fieldId;

      query('thead th[data-sort-field] i', 
      this.domTable).removeClass('visible');

      domClass.replace(sortIcon, 
      this.sortDesc ? 'icon-caret-down' : 'icon-caret-up');
      domClass.add(sortIcon, 'visible');

      this.update(true);
    },

    /** 
    * Filter query implementation. 
    * Splits filter string by whitespace and does AND-matching over
    * all grid columns. OR-matching is done with '|' separators, e.g.:
    * apple|banana shake -> (apple OR banana) AND shake
    * @method filterQuery
    * @private
    * */
    filterQuery: function (item) {
      var i, key, haystack = '', needleArr, value;

      if (this.filterQueryCallback && !this.filterQueryCallback(item)) {
        return false;
      }

      for (key in item) {
        if (item.hasOwnProperty(key)) {
          value = this.dataValueCallback(key, item[key], item);
          haystack += ('"' + value + '"').toLowerCase();
        }
      }


      function matcher(match) {
        return (haystack.indexOf(match) >= 0);
      }

      needleArr = this.filterString.toLowerCase().split(' ');

      for (i = 0; i < needleArr.length; i += 1) {
        if (!array.some(needleArr[i].split('|'), matcher)) {
          return false;
        }
      }
      return true;
    },

    /**
    * Adds callback (i.e. for action menu) on row clicks
    * @method addRowCallbackHook
    * @private
    * */
    addRowCallbackHook: function (id, node) {
      if (!this.rowClickCallback) {
        return;
      }
      on(node, 'click', 
        lang.hitch(this, lang.partial(this.rowClickCallback, id, node)));
    },

    /**
    * Show "nothing found" message if there are no rows to be shown-
    * @method updateNothingFound
    * @private
    * */
    updateNothingFound: function () {
      var count = query('tr', this.domTBody).length;
      this.domNothingFound.replaceClass(count ? 'hide' : '');
    },

    /**
    * Updates the grid. Required if sorting or query (aka. filtering)
    * changes. Adds a new listener hook after initial query.
    * @method update
    * @private
    * */
    update: function (queryChanged) {
      var query;

      if (queryChanged) {
        this.maxItems = this.defaultMaxItems;
      }

      this.indexToDom = [];
      domConstruct.empty(this.domTBody);

      query = this.store.query(lang.hitch(this, this.filterQuery), {
        sort: [ {
          attribute: this.sortFieldId, 
          descending: this.sortDesc 
        } ],
        count: this.maxItems
      });

      this.scrolledAllItems = (query.length < this.maxItems);

      // populate grid with initial data
      // this is faster than using "listener" for all data
      query.forEach(lang.hitch(this, function (data) {
        var node = domConstruct.create('tr', {
          innerHTML: this.tcRow(this.compileData(data))
        }, this.domTBody, 'last');

        this.indexToDom.push(node);
        this.idToDom[data.id] = node;
        this.addRowCallbackHook(data.id, node);
      }));

      if (this.observer) {
        this.observer.cancel();
      }

      this.observer = query.observe(lang.hitch(this, this.listener), true);

      this.updateNothingFound();
      this.scroll();
    },

    /**
    * Creates data structs for Grid row
    * @method compileData
    * @private
    * */
    compileData: function (data) {
      var key, result = { classes: {}, data: {}, title: {} };

      for (key in data) {
        if (data.hasOwnProperty(key)) {
          result.classes[key] = this.dataClassCallback(key, data[key], data);
          result.data[key] = this.dataValueCallback(key, data[key], data);

          // strip html from title tags
          result.title[key] = 
          this.dataTitleCallback(key, data[key]).replace(/<.*?>/gm, '');
        }
      }
      return result;
    },

    /**
    * Listener method (called by Observable store)
    * @method listener
    * @private
    * */
    listener: function (object, removedFrom, insertedInto) {
      var node, className, refNode, placeMode;

      // update without moving
      if (insertedInto === removedFrom) {
        node = domConstruct.create('tr', {
          innerHTML: this.tcRow(this.compileData(object))
        }, this.idToDom[object.id], 'replace');

        this.indexToDom[insertedInto] = node;
        this.idToDom[object.id] = node;
        this.addRowCallbackHook(object.id, node);

        domClass.add(node, 'warning');
        setTimeout(function () { 
          domClass.remove(node, 'warning'); 
        }, this.animDuration);

        // no need to remove and add separately
        return;
      }

      // remove
      if (removedFrom > -1) {
        node = this.indexToDom[removedFrom];
        this.indexToDom.splice(removedFrom, 1);
        delete this.idToDom[object.id];

        // really removed, not just moved
        if (insertedInto < 0) {
          domClass.add(node, 'error');
          setTimeout(
            lang.partial(domConstruct.destroy, node),
          this.animDuration);
        }
        else {
          domConstruct.destroy(node);
        }
      }

      // add
      if (insertedInto > -1) {
        refNode = this.indexToDom[insertedInto];
        placeMode = 'before';
        if (!refNode) {
          refNode = this.domTBody;
          placeMode = 'first';
        }

        node = domConstruct.create('tr', {
          innerHTML: this.tcRow(this.compileData(object))
        }, refNode, placeMode);

        this.indexToDom.splice(insertedInto, 0, node);
        this.idToDom[object.id] = node;
        this.addRowCallbackHook(object.id, node);

        // really added or just moved?
        className = (removedFrom < 0) ? 'success' : 'warning';

        domClass.add(node, className);
        setTimeout(
          lang.partial(domClass.remove, node, className),
        this.animDuration);
      }

      // wait for nodes to be removed
      setTimeout(
        lang.hitch(this, this.updateNothingFound), 
        this.animDuration * 1.1
      );
    },

    dataClassCallback: function () { return ''; },
    dataTitleCallback: function () { return ''; },
    dataValueCallback: function (_d1, value) { return value; }
  });
});

