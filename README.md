# Iron Router SEO for Meteor

This package lets you add `meta` tags to your Meteor app from Iron Router routes in countless ways.

```coffeescript
Router.route 'blogPost',
  path: '/blog/:id'
  seo:
    title: ->
      this.data().title
    meta:
      keywords: ['blog', 'post']
      author: 'Johan'

    description: ->
      this.data().content.substr(0, 25)
    image: ->
      $(this.data().content).find('img:first').attr 'src'

    twitter:
      creator: ->
        '@' + this.data().author.twitter

    og:
      type: 'homepage'

  data: ->
    Posts.findOne(this.params.id)
```

## Why?

Currently, Meteor render templates client side. That means, we cannot dynamically manipulate the `head` section in our HTML when rendering templates. This package is able to automatically on route change render:

- `title`
- `keywords`
- `description`
- OpenGraph
- Twitter Card

All customizable from your routes.

Example: you have a dedicated `blogPost` route and you want to insert the usual `meta` tags (`author`, `keywords`, `description`, perhaps OpenGraph and Twitter Cards) from the blog post's content. You have to do that from the client when the route runs.

## Install

Install [`lookback:seo`](https://atmospherejs.com/lookback/seo) from Atmosphere:

```bash
meteor add lookback:seo
```

## Usage

This package exists as an [Iron Router plugin](https://github.com/iron-meteor/iron-router/blob/devel/Guide.md#plugins). You initialize it like this (client only!):

```js
Router.plugin('seo', options);
```

The `options` object can be as follows:

```js
Router.plugin('seo', {
  only: ['someRoute'],
  except: ['someOtherRoute'],

  defaults: { /* Default SEO fields. */ }
});
```

`only` and `except` applies to Iron Router, i.e. this SEO package won't run or will only run on those routes. The `defaults` should include values which should be *global fallbacks* if those properties are not present on the current route.

Example:

```javascript
var defaults = {
  title: 'My Site Title',                 // Will apply to <title>, Twitter and OpenGraph.
  suffix: 'My Site',
  separator: '·',

  description: 'Some description',        // Will apply to meta, Twitter and OpenGraph.
  image: 'http://domain.com/image.png',   // Will apply to Twitter and OpenGraph.

  meta: {
    keywords: ['tag1', 'tag2']
  },

  twitter: {
    card: 'summary',
    creator: '@handle'
    // etc.
  },

  og: {
    site_name: 'Your Site',
    image: '/images/custom-opengraph.png'
    // etc.
  }
};
```

The `description` and `image` properties will apply to both Twitter cards and OpenGraph tags, unless overridden in their respective sub-properties. `title` will be applied to Twitter, OpenGraph, and the `<title>` tag.

### Different ways to set the values

Strings and arrays are not the only values accepted as properties – functions are too! That's handy for computing values from your route or other data sources:

```js
Router.route('home', {
  path: '/',
  data: function() {
    return {
      posts: Posts.find()
    };
  },
  seo: {
    title: function() {
      return 'Found ' + this.data().posts.count() + ' posts';
    }
  }
});
```

The context of `this` in all SEO functions is the current route context.

The SEO functions are run reactively, so this will work just fine when the session variable changes:

```js
Router.route('home', {
  path: '/',
  seo: {
    title: function() {
      return Session.get('title');
    }
  }
});
```

### Title

`title` will per default be formatted as

```
Title Separator Suffix
```

Separator defaults to a single dot: `·`. Both `suffix` and `separator` is customizable from `defaults`, but can also be manipulated at runtime:

```js
Router.route('home', {
  path: '/',
  seo: {
    title: {
      text: 'My Text',
      suffix: 'Custom suffix',
      separator: '|'
    }
  }
});
```

If you set `suffix` to `null`, you'll explicitly tell the SEO package to not include a suffix, and will thus only render the `text` as title.

*Note:* This package will automatically add the OpenGraph namespace to the `html` element: `og: http://ogp.me/ns#`.

### Setting values manually

This package only runs on the router's `onAfterAction` hook. Under the hood, we use the [`blaze-meta`](https://atmospherejs.com/yasinuslu/blaze-meta) package to reactively render the actual HTML tags into the DOM.

The global `Meta` helper from `blaze-meta` is exposed for you on the client, in order to set individual tags.

## Version history

- `1.0.0` - Initial publish.

## Tests

Rudimentary tests exists as Mocha integrations tests in a separate app: `test-app`. Run with:

```bash
cd test-app
meteor --test
```

## Contributions

Contributions are welcome. Please open issues and/or file Pull Requests.

## License

MIT.

***

Made by [Lookback](http://github.com/lookback).
