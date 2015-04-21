should = chai.should()

meta = (prop) ->
  $("meta[name='#{prop}']")

property = (name) ->
  $("meta[property='#{name}']")

MochaWeb?.testOnly ->

  describe 'Lookback SEO', ->

    beforeEach waitForRouter

    describe 'defaults', ->
      it 'should defer to default values if not SEO props are set', ->
        document.title.should.equal 'PAGE TITLE · Lookback'
        property('og:title').should.have.attr 'content', 'PAGE TITLE'
        property('twitter:title').should.have.attr 'content', 'PAGE TITLE'

        property('twitter:description').should.have.attr 'content', 'DESCRIPTION'
        property('og:description').should.have.attr 'content', 'DESCRIPTION'

        meta('description').should.have.attr 'content', 'DESCRIPTION'
        meta('keywords').should.have.attr 'content', 'lookback'

    describe 'url', ->

      it 'should use the current URL', ->
        property('og:url').should.have.attr 'content', location.href
        property('twitter:url').should.have.attr 'content', location.href

    describe 'title', ->

      it 'should be able to be set as string', (done) ->
        Router.go 'string'

        Meteor.setTimeout ->
          document.title.should.equal 'String title · Lookback'
          done()
        , 10

      it 'should be able to be set from a function', (done) ->
        Router.go 'function'

        Meteor.setTimeout ->
          document.title.should.equal 'Function title · Lookback'
          done()
        , 10

      it 'should be able to be set from an object', (done) ->
        Router.go 'object'

        Meteor.setTimeout ->
          document.title.should.equal 'Object title · Suffix'
          done()
        , 10

      it 'should be able to be set from an object with functions', (done) ->
        Router.go 'objectFunctions'

        Meteor.setTimeout ->
          document.title.should.equal 'Object function title · Suffix'
          done()
        , 10

      it 'should be able have no suffix', (done) ->
        Router.go 'no-suffix'

        Meteor.setTimeout ->
          document.title.should.equal 'Object title'
          done()
        , 10

      it 'should be able to be set from a reactive function', (done) ->
        Router.go 'session'

        Meteor.setTimeout ->
          document.title.should.equal 'Session title · Lookback'

          Session.set 'title', 'New title'
          Tracker.flush()

          document.title.should.equal 'New title · Lookback'

          done()
        , 10

      it 'should be able to be set from a data context', (done) ->
        Router.go 'data'

        Meteor.setTimeout ->
          document.title.should.equal 'Post title · Lookback'
          done()
        , 10
