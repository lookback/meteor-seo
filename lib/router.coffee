# # Iron Router SEO
#
# For Meteor.
#
# - GitHub: [meteor-seo](https://github.com/lookback/meteor-seo)
# - Atmosphere: [lookback:seo](https://atmospherejs.com/lookback/seo)
#
# Written by Johan Brook for Lookback.

# Convenience function for calling a function `val` with the
# scope of the current route *if* it's indeed function.
callOrGet = (router, val) ->
  if _.isFunction(val) then val.call(router) else val

# ## Formatter
#
# A Formatter *returns a function* which is used to format
# its arguments into a general `meta` tag:
#
# ```html
# <meta name="name" content="content">
# ```
# When constructing a formatter, the `opts.name` option must be set. This
# corresponds to the `name` attribute on the `meta` tag. `opts.prefix` may
# also be provided, and will prefix the `content` variable (see below). Useful
# in Twitter and OpenGraph formatters.
#
# The returned function takes two arguments: `content` and `key`.
#
# `content` can be a function, array, or string. If it's a function,
# it will be called with `this` bound to the scope of the returned function.
#
# If `content` is an array, it will be joined to a string, separated by `,` chars.
#
# Example:
#
# ```coffeescript
# TwitterFormatter = Formatter name: 'property', prefix: 'twitter'
# TwitterFormatter('http://domain.com', 'url')
# => <meta property="twitter:url" content="http://domain.com">
#
# MetaFormatter = Formatter name: 'name'
# MetaFormatter 'This is desc', 'description'
# => <meta name="description" content="This is desc">
#```
Formatter = (opts) ->
  check opts.name, String

  return (content, key) ->
    return if not content

    if not Match.test content, Match.OneOf(String, Function, Array)
      return console.warn "Content for #{key} must be a function, array, or string!", content

    content = if _.isFunction(content) then content.call(this) else content
    prefix = if opts.prefix then opts.prefix+':' else ''
    property = "#{prefix}#{key}"

    content = if Array.isArray(content) then content.join(', ') else content

    Meta.set
      name: opts.name
      property: property
      content: content

# Create formatters for OpenGraph, Twitter and regular meta tags.
OpenGraphFormatter = Formatter name: 'property', prefix: 'og'

TwitterFormatter = Formatter name: 'name', prefix: 'twitter'

MetaFormatter = Formatter name: 'name'

# This is a title formatter, which will format the `<title>` tag (surprise).
# It will take suffixes and separators in account.
#
# A custom suffix can be provided by calling this formatter with `title`
# as an object: `{ text: 'Title', suffix: 'My Suffix' }`. A custom separator
# can be provided to the `defaults` object.
#
# If `title.suffix` is explicitly set to `null`, no suffix is incldued. If
# `title.suffix` is not included at all, suffix will fallback to `defaults.suffix`
# if set.
#
# This formatter also sets the `og:title` and `twitter:title` meta property
# tags.
#
# The scope of `this` is the current router.
TitleFormatter = (title, defaults) ->
  separator = defaults.separator or '·'
  suffix = defaults.suffix

  if _.isObject(title)
    if Match.test title, Match.ObjectIncluding(
      text: Match.OneOf(String, Function)
    )
      suffix = callOrGet(this, title.suffix) unless _.isUndefined(title.suffix)
      stringTitle = callOrGet(this, title.text)

  else
    stringTitle = title

  if not Match.test stringTitle, String
    return console.warn 'Title must be a string!'

  browserTitle = stringTitle
  if suffix and suffix isnt null
    browserTitle += " #{separator} #{suffix}"

  # Bypass Meta package's setTitle, since we wanna compose our own.
  Meta.setVar 'title', browserTitle
  TwitterFormatter stringTitle, 'title'
  OpenGraphFormatter stringTitle, 'title'

# ## Computations
#
# Keep track (pun not intended) of all computations that's been
# made in the route functions, i.e. if a route has this:
#
# ```coffeescript
# Router.route 'name',
#   seo:
#     twitter:
#       creator: ->
#         this.data().post.author
# ```
#
# Since that `creator` function will be actively re-run on
# route change, we need to stop it to prevent exceptions and
# other boring stuff. Therefore, run `Computations.clear()` in
# the Router's `onStop` hook to clear everything we've made.
Computations =
  _comps: []

  add: (c) ->
    @_comps.push(c)
    return this

  clear: ->
    return this if @_comps.length is 0

    _.invoke(@_comps, 'stop')
    @_comps = []
    return this

# ## Main
#
# Main route callback function.
#
# Will scrape the properties on the `seo` object on the route (if provided)
# and set relevant meta properties in `<head>`.
#
# All functions on the `seo` object will be called reactively.
run = (defaults = {}) ->
  router = this
  seo = this.lookupOption('seo') or {}

  call = _.partial(callOrGet, router)

  # Inherit a property or list of properties from the parent
  # `seo` object if it isn't available on `obj`. If not available
  # on `seo`, try from `defaults`.
  inheritFromParent = (obj, props) ->
    if not Array.isArray(props)
      props = [props]

    check obj, Object
    check props, Array

    props.forEach (prop) ->
      unless obj[prop]
        if seo[prop]
          obj[prop] = seo[prop]
        else if defaults[prop]
          obj[prop] = defaults[prop]


  Tracker.autorun (c) ->
    Computations.add(c)

    title = call(seo.title or defaults.title)
    TitleFormatter.call(router, title, _.pick(defaults, 'suffix', 'separator'))

    twitter = _.extend({}, defaults.twitter, seo.twitter)
    og = _.extend({}, defaults.og, seo.og)
    meta = _.extend({}, call(seo.meta or defaults.meta))

    inheritFromParent twitter, ['image', 'description']
    inheritFromParent og, ['image', 'description']
    inheritFromParent meta, 'description'

    # For each property, use it's formatter.
    _.each og, OpenGraphFormatter.bind(router)
    _.each twitter, TwitterFormatter.bind(router)
    _.each meta, MetaFormatter.bind(router)

    # Set the URL property for OpenGraph and Twitter tags
    # from the current URL.
    #
    # This is why we call the `run` function in Meteor's
    # `afterFlush` callback – otherwise, `location.href` isn't
    # available to us.
    url = seo.url or location.href
    url = call url
    TwitterFormatter url, 'url'
    OpenGraphFormatter url, 'url'

# ## Init

# Add necessary OpenGraph html attribute.
Meteor.startup ->
  $('html').attr 'prefix', 'og: http://ogp.me/ns#'

{onReady, once} = share.RouterUtils

# Iron Router plugin definition. Called like:
#
# ```coffeescript
# Router.plugin 'seo',
#   defaults: <default SEO object>
#   only: ['myRoute']
#   except: ['someOther']
# ```
Iron.Router.plugins.seo = (router, options = {}) ->
  defaults = options.defaults or {}

  defaultTitle = do ->
    title = defaults.title
    if not title or title is ''
      return ''

    if Match.test title, Function
      return title()

    if Match.test title, Match.ObjectIncluding(text: String)
      return title.text

    return title

  # Make sure to initialize the `Meta` package with an initial title.
  Meta.config(
    options:
      title: defaultTitle
  )

  # Function composition ftw. Use the utils `onReady` and `once` to ensure that
  # the seo scraping will be done when the route is ready, and only to it *once*.
  #
  # Hook it up to Iron Router's `onAfterAction` hook, and also make sure to
  # stop all potential computations when the route stops.
  runWhenReady = onReady once _.partial(run, defaults)

  routeOptions = _.pick(options, 'only', 'except')

  router.onAfterAction(runWhenReady, routeOptions)

  router.onStop ->
    Computations.clear()
