define([
  './bootstrap',
  'dojo/query'
], 
function (
  bootstrap, query
) {
  var curModule = null;

  /** 
  * Loads a new module and destroys the old one properly.
  * @class module
  * @module root
  * @static
  * */

  /**
  * @method module
  * @param module {Object} Module object containing `initialize` 
  *   and `destroy` methods.
  * */
  return {
    load: function (Module, args) {
      if (curModule !== null) {
        bootstrap.clearPopover();
        query('#main').removeClass('in');
        curModule.destroy();
      }

      setTimeout(function () {
        curModule = new Module(args);
        query('#main').addClass('in');
      }, 150);
    }
  };

});
