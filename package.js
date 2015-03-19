var where = 'client';

Package.describe({
  name: 'lookback:seo',
  summary: 'Automatically meta, OpenGraph and Twitter tags for your Iron Router routes.',
  version: '1.0.0',
  git: 'http://github.com/lookback/meteor-seo'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.3');

  api.imply('yasinuslu:blaze-meta@0.3.1', where);

  api.use([
    'coffeescript',
    'tracker',
    'underscore',
    'check',
    'jquery',
    'iron:router'
  ], where);

  api.addFiles([
    'lib/router-utils.coffee',
    'lib/router.coffee'
  ], where);
});
