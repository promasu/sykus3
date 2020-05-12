/* exported profile */
var profile = {
  resourceTags: {
    test: function () {
      return false;
    },
    copyOnly: function () {
      return false;
    },
    amd: function (filename) {
      return (/\.js$/).test(filename);
    },
    miniExclude: function () {
      return false;
    }
  }
};

