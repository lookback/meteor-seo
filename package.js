var where = 'client';

Package.describe({
  name: 'lookback:seo',
  summary: 'Automatically add meta, OpenGraph and Twitter tags from your Iron Router routes.',
  version: '1.1.2',
  git: 'http://github.com/lookback/meteor-seo'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.3');

  api.imply('yasinuslu:blaze-meta@0.3.1', where);

  api.use([
    'mongo',
    'coffeescript',
    'tracker',
    'underscore',
    'check',
    'jquery',
    'iron:router@1.0.7'
  ], where);

  api.addFiles([
    'lib/router-utils.coffee',
    'lib/router.coffee'
  ], where);
});
