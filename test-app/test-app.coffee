if Meteor.isClient

  @Posts = new Mongo.Collection(null)

  Meteor.startup ->
    Posts.insert {
      title: 'Post title'
      author: 'Johan'
      twitter: '@johanbrook'
      excerpt: 'Lorem ipsum.'
    }

  Settings =
    title: 'PAGE TITLE'
    suffix: 'Lookback'
    image: 'http://lookback.io/images/og-image.png'
    description: 'DESCRIPTION'
    meta:
      keywords: ['lookback']
    twitter:
      site: '@lookback'
      domain: 'lookback.io'
      creator: '@lookback'
      card: 'summary'
    og:
      site_name: 'Lookback'
      type: 'product'

  Router.configure(
    layoutTemplate: 'layout'
  )

  Router.plugin 'seo', defaults: Settings

  Router.onAfterAction ->
    Tracker.afterFlush ->
      Session.set 'meta', $('meta').map(-> @outerHTML).toArray().join('\n')

  Template.layout.helpers(
    meta: ->
      Session.get 'meta'
  )

  Template.home.created = ->
    Session.setDefault 'title', 'Session title'
    Session.setDefault 'dynamic', 'DYNAMIC VALUE'

  Router.route 'home',
    path: '/'
    data: ->
      page: 'Home'

  Router.route 'string',
    template: 'home'
    seo:
      title: 'String title'
    data: ->
      page: 'String'

  Router.route 'session',
    template: 'home'
    seo:
      title: ->
        Session.get 'title'

    data: ->
      page: 'Session'

  Router.route 'object',
    template: 'home'
    seo:
      title:
        text: 'Object title'
        suffix: 'Suffix'

    data: ->
      page: 'Object'

  Router.route 'objectFunctions',
    template: 'home'
    seo:
      title:
        text: ->
          'Object function title'
        suffix: ->
          'Suffix'

    data: ->
      page: 'Object-Functions'

  Router.route 'no-suffix',
    template: 'home'
    seo:
      title:
        text: 'Object title'
        suffix: null

    data: ->
      page: 'Object'

  Router.route 'function',
    template: 'home'
    seo:
      title: -> 'Function title'

    data: ->
      page: 'Function'

  Router.route 'props',
    template: 'home'
    seo:
      title: -> 'Props title from function'
      twitter:
        creator: ->
          Session.get 'dynamic'

    data: ->
      page: 'Advanced Props'

  Router.route 'data',
    template: 'home'
    seo:
      title: ->
        this.data().post.title

      twitter:
        creator: ->
          this.data().post.title
      og:
        description: ->
          this.data().post.excerpt
        image: 'Custom OG image URL'
      meta:
        description: ->
          this.data().post.excerpt

    data: ->
      post: Posts.findOne()
