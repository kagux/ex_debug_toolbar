exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
        "js/toolbar.js": /^(web\/static\/js\/toolbar)|^node_modules/,
      }
    },
    stylesheets: {
      joinTo: {
        "css/toolbar.css": /^(web\/static\/css\/toolbar)|^node_modules/,
      },
      order: {
        after: /prism/
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    copycat:{
      "fonts" : ["node_modules/bootstrap-sass/assets/fonts"],
      verbose : true, //shows each file that is copied to the destination directory
      onlyChanged: true //only copy a file if it's modified time has changed (only effective when using brunch watch)
    },
    sass: {
      options: {
        mode: 'ruby',
        includePaths: [
          'node_modules/bootstrap-sass/assets/stylesheets/',
          'node_modules/css-reset-and-normalize-sass/scss/',
          'node_modules/'
        ],
      }
    }
  },

  modules: {
    autoRequire: {
      "js/toolbar.js": ["web/static/js/toolbar"]
    }
  },

  npm: {
    styles: {
    },
    enabled: true
  }
};
