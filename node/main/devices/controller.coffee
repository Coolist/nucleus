# Load Node modules
Q = require 'q'

# Load related model/response
model = require './model.coffee'
validate = require './validation.coffee'
check = require '../authentication/check'

# Helpers
errors = require '../helpers/errors.coffee'

# GET device by ID
exports.getOne = (req, res) ->

  check.permissions req, 1
  .then () ->
    model.readOne
      placeId: req.params.placeId
      id: req.params.id
  .then (response) ->
    res.send response, 200
  .fail (error) ->
    errors.send error, res
  .done()

# GET devices by device ID
exports.get = (req, res) ->

  check.permissions req, 1
  .then () ->
    model.read
      placeId: req.params.placeId
  .then (response) ->
    res.send response, 200
  .fail (error) ->
    errors.send error, res
  .done()
  
# POST new device
###
exports.post = (req, res) ->

  check.permissions req, 2
  .then () ->
    validate.post req
  .then (sanitized) ->
    model.create sanitized
  .then (id) ->
    res.send
      success: true
      messages: [ 'Space successfully created.' ]
      id: id
    , 200
  .fail (error) ->
    errors.send error, res
  .done()
###

# UPDATE device by ID
exports.update = (req, res) ->

  check.permissions req, 2
  .then () ->
    validate.update req
  .then (sanitized) ->
    model.update sanitized
  .then () ->
    res.send
      success: true
      messages: [ 'Space successfully updated.' ]
    , 200
  .fail (error) ->
    errors.send error, res
  .done()

# DELETE device by ID
exports.delete = (req, res) ->

  check.permissions req, 2
  .then () ->
  Q.fcall () ->
    model.delete
      id: req.params.id
  .then (response) ->
    res.send
      success: true
      messages: [ 'Space successfully deleted.' ]
  .fail (error) ->
    errors.send error, res
  .done()