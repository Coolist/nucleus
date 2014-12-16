# Load Node modules
should = require 'should'
request = require 'supertest'

# Load configuration file
config = '../../node/config.json'

if config.environment is not 'development'
  throw Error 'Tests must be running on a development environment.'

# Variables
api = 'http://localhost:3000/api/1'

describe 'Projects', () ->
  it 'should create a place', (done) ->
    request api
      .post '/places'
      .send
        name: 'Test Project'
      .end (e, res) ->
        res.status.should.equal 200
        res.body.success.should.equal true
        res.body.id.length.should.be.above 1
    done()

  it 'should not create a place when name is blank', (done) ->
    request api
      .post '/places'
      .send
        name: undefined
      .end (e, res) ->
        res.status.should.equal 400
        res.body.success.should.equal false
        done()

  it 'should get all places as well as a single place by id', (done) ->
    request api
      .get '/places'
      .end (e, res) ->
        res.status.should.equal 200
        res.body.length.should.be.above 0
        res.body[0].id.length.should.be.above 1

        request api
          .get '/places/' + res.body[0].id
          .end (e, res) ->
            res.status.should.equal 200
            res.body.id.length.should.be.above 0
            done()

  it 'should update a place by id', (done) ->
    request api
      .get '/places'
      .end (e, res) ->
        placeId = res.body[0].id

        request api
          .put '/places/' + placeId
          .send
            name: 'Renamed Test Project'
          .end (e, res) ->
            res.status.should.equal 200
            res.body.success.should.equal true

            request api
              .get '/places/' + placeId
              .end (e, res) ->
                res.body.name.should.equal 'Renamed Test Project'
                done()

  it 'should delete a place by id', (done) ->
    request api
      .get '/places'
      .end (e, res) ->

        placeId = res.body[0].id

        request api
          .delete '/places/' + placeId
          .end (e, res) ->
            res.status.should.equal 200
            res.body.success.should.equal true

            request api
              .get '/places/' + placeId
              .end (e, res) ->
                res.status.should.equal 404
                done()
