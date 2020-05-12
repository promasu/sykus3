window.dojoConfig = {
  packages: [ 
    // REVIEW
    // hack to work around faulty dojo cache behaviour
    // this seems to be a bug introduced in dojo 1.9
    //
    // without this, dojo/text objects get saved as '../app/X' in cache
    // by #require, but #dojo/text wants to receive them as 'app/X'.
    { name: 'app', location: 'app' },

    // find correct dojo nls dir (for runtime XHR)
    { name: 'dojo', location: 'app/{{VERSIONDIR}}' }
  ]
};

