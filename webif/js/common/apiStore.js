define([
  'dojo/DeferredList', 
  'dojo/store/JsonRest', 
  'dojo/store/Memory', 
  'dojo/store/Observable',
  'dojo/_base/lang',
  'dojo/_base/array',
  'dojo/request',
  'dojo/aspect',
  '../xhrerror'
], 
function (
  DeferredList, JsonRest, Memory, Observable, lang, array, 
  request, aspect, xhrerror
) {
  var refreshTimeout = 3000;
  var storeList = {};
  var timerList = [];
  var deferredList = [];

  /** 
  * Grid store wrapper class. Uses a JSON REST store for getting and
  * setting data. Caches all data locally in a Memory store. 
  *
  * Receives update diffs from server and applies to Memory store.
  * Write actions are passed on to server.
  *
  * Keeps record of created stores and returns the already
  * created instance if present.
  *
  * @class apiStore
  * @module Common
  * @static
  * */

  /**
  * @method apiStore
  * @param target {String} API Target.
  * @param hasNoChangeEvents {Boolean} Store does not support diffs.
  * @return {Store} Store object.
  * */
  var createApiStore = function (target, hasNoChangeEvents) {
    var apiStore, cacheStore, dataStore, pollTimestamp = 0, ready;

    // don't create multiple instances of the same store
    if (storeList.hasOwnProperty(target)) {
      return storeList[target];
    }

    cacheStore = new Observable(new Memory());
    dataStore = new JsonRest({ target: target });

    // create a store object for the grid
    // get and query uses local store
    // all other actions use data store
    apiStore = lang.delegate(cacheStore, {
      add: lang.hitch(dataStore, dataStore.add),
      put: lang.hitch(dataStore, dataStore.put),
      remove: lang.hitch(dataStore, dataStore.remove),

      // modifying get results should not alter store
      get: function (id) { return lang.clone(cacheStore.get(id)); }
    });

    // poll for changes to dataset
    function poll() {
      if (!hasNoChangeEvents) {
        request.get(
          target + 'diff/' + pollTimestamp,
          { handleAs: 'json' }
        ).then(function (data) {
          pollTimestamp = data.timestamp;

          array.forEach(data.updated, function (element) {
            cacheStore.put(element);
          });
          array.forEach(data.deleted, function (element) {
            cacheStore.remove(element);
          });
        }, xhrerror);
      }
    }


    // wait for write request to finish before 
    // starting to poll (otherwise race-condition)
    function pollWhenSaved(arg) {
      arg.then(poll);

      // pass on argument for aspect.after
      return arg;
    }

    // poll() before populating store with initial data to 
    // get initial timestamp (this call does not return data yet)
    poll();

    // populate local store with all data
    // add Deferred to apiStore to notify Grid when store is ready
    ready = dataStore.query({}).forEach(function (element) {
      cacheStore.put(element);
    }).then(function () {
      // wait for initial loading to complete to avoid 
      // race conditions between initial and diff data
      poll();
      timerList.push(setInterval(poll, refreshTimeout));

      aspect.after(apiStore, 'add', pollWhenSaved);
      aspect.after(apiStore, 'put', pollWhenSaved);
      aspect.after(apiStore, 'remove', pollWhenSaved);
    });
    deferredList.push(ready);

    storeList[target] = apiStore;

    return apiStore;
  };

  /** 
  * Clears all saved and active stores
  * @method apiStore.clearStores
  * */
  createApiStore.clearStores = function () {
    var i;
    for (i = 0; i < timerList.length; i += 1) {
      clearInterval(timerList[i]);
    }
    timerList = [];
    deferredList = [];
    storeList = {};
  };

  /**
  * Returns a Deferred that resolves when all
  * currently existing apiStore instances are ready.
  * @method apiStore.allReady
  * @return [Deferred]
  * */
  createApiStore.allReady = function () {
    return new DeferredList(deferredList);
  };

  return createApiStore;
});

