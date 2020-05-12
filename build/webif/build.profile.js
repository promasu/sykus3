var profile = {
  action: 'release',
  mini: true,
  layerOptimize: false,
  optimize: false,
  selectorEngine: 'lite',
  stripConsole: 'all',

  localeList: 'de',

  defaultConfig: {
    isDebug: 0,
    async: 1,
    locale: 'de',
    deps: [ 'app/run' ]
  }, 

  layers: {
    'dojo/dojo': {
      include: [ 'app/run' ],
      boot: true,
      customBase: true
    }
  },

  staticHasFeatures: {
    'ie': undefined,
    'opera': undefined,
    'dom-quirks': undefined,
    'quirks': undefined,
    'activex': undefined,
    'jscript': undefined,
    'ie-event-behavior': 0,
    'dom-addeventlistener': 1,

    'dom': 1,
    'native-xhr': 1,

    'host-browser': 1,
    'host-node': 0,
    'host-rhino': 0,

    'json-stringify': 1,
    'json-parse': 1,

    'dojo-preload-i18n-Api': 1,
    'dojo-force-activex-xhr': 0,
    'dojo-inject-api': 1,
    'dojo-loader-eval-hint-url': 1,
    'dojo-built': 1,
    'dojo-debug-messages': 0,
    'dojo-guarantee-console': 0,
    'dojo-trace-api': 0,
    'dojo-sync-loader': 0,
    'dojo-config-api': 1,
    'dojo-cdn': 0,
    'dojo-sniff': 0,
    'dojo-requirejs-api': 0,
    'dojo-test-sniff': 0,
    'dojo-combo-api': 0,
    'dojo-undef-api': 0,
    'dojo-unit-tests': 0,
    'dojo-timeout-api': 0,
    'dojo-dom-ready-api': 0,
    'dojo-log-api': 0,
    'dojo-amd-factory-scan': 0,
    'dojo-publish-privates': 0,

    'config-deferredInstrumentation': 0,
    'config-useDeferredInstrumentation': 0,
    'config-tlmSiblingOfDojo': 0,
    'config-dojo-loader-catches': 1,
    'config-stripStrict': 0
  }
};

