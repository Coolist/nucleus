# Load Node modules
Q = require 'q'

# Load related model/response
model = require './model.coffee'
validate = require './validation.coffee'
check = require '../authentication/check'

# Helpers
errors = require '../helpers/errors.coffee'

# GET accesses
exports.get = (req, res) ->
  
  check.permissions req, 1, 'You must have viewer permissions to view users who have access to this place.'
  .then () ->
    model.get
      placeId: req.params.placeId
  .then (accounts) ->
    res.send accounts
    , 200
  .fail (error) ->
    errors.send error, res
  .done()
  
# POST new access
exports.post = (req, res) ->
  
  check.permissions req, 2, 'You must have owner or editor permissions to assign a role to a user.'
  .then () ->
    validate.post req
  .then (sanitized) ->
    model.create sanitized
  .then (id) ->
    res.send
      success: true
      messages: [ 'Access to place successfully granted.' ]
    , 200
  .fail (error) ->
    errors.send error, res
  .done()

# UPDATE access
exports.update = (req, res) ->

  Q.fcall () ->
    validate.update req
  .then (sanitized) ->
    model.update sanitized
  .then (id) ->
    res.send
      success: true
      messages: [ 'User role successfully modified.' ]
    , 200
  .fail (error) ->
    errors.send error, res
  .done()

# DELETE access
exports.delete = (req, res) ->

  Q.fcall () ->
    validate.delete req
  .then (sanitized) ->
    model.delete sanitized
  .then (id) ->
    res.send
      success: true
      messages: [ 'User role successfully removed.' ]
    , 200
  .fail (error) ->
    errors.send error, res
  .done()