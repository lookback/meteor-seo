# # Utils
#
# Handy router filters.
share.RouterUtils =

  # Wraps a filter and ensures it only run once for the route.
  once: (fn) ->
    return () ->
      ran = @hasRunOnceFunctions = @hasRunOnceFunctions or []

      if not _.contains(ran, fn)
        fn.call(this)
        ran.push(fn)

  # Wraps a filter so it only runs if the route is ready (data loaded, etc.)
  onReady: (fn) ->
    return () ->
      return if not @ready()
      Tracker.afterFlush(fn.bind(this))
