# Load Node modules
Q = require 'q'

# Load related model/response
model = require './model.coffee'
check = require '../authentication/check'

# Helpers
errors = require '../helpers/errors.coffee'
  
# GET new device auth redirect URL
exports.getRedirect = (req, res) ->

  Q.fcall () ->
    model.getRedirect req.params.service
  .then (url) ->
    res.redirect url
  .fail (error) ->
    errors.send error, res
  .done()

# GET activate device URL redirect
exports.getActivate = (req, res) ->

  Q.fcall () ->
    model.getActivate req
  .then (url) ->
    res.redirect url
  .fail (error) ->
    errors.send error, res
  .done()

# POST service
exports.postService = (req, res) ->

  check.permissions req, 3
  .then () ->
    model.activateService
      token: req.query.token
      service: req.params.service
      authToken: req.body.auth_token
      place: req.params.placeId
  .then () ->
    res.send
      success: true
      messages: [ 'Service successfully activated.' ]
    , 200
  .fail (error) ->
    errors.send error, res
  .done()