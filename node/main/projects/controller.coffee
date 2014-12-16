# Load Node modules
Q = require 'q'

# Load related model/response
model = require './model.coffee'
validate = require './validation.coffee'
check = require '../authentication/check'

# Helpers
errors = require '../helpers/errors.coffee'

# GET Project by ID
exports.getOne = (req, res) ->

  check.permissions req, 1
  .then () ->
    model.readOne
      id: req.params.id
  .then (response) ->
    res.send response, 200
  .fail (error) ->
    errors.send error, res
  .done()

# GET projects (shared with user)
exports.get = (req, res) ->

  Q.fcall () ->
    model.read
      token: req.query.token
  .then (response) ->
    res.send response, 200
  .fail (error) ->
    errors.send error, res
  .done()
  
# POST new projects
exports.post = (req, res) ->

  Q.fcall () ->
    validate.post req
  .then (sanitized) ->
    model.create sanitized
  .then (id) ->
    res.send
      success: true
      messages: [ 'Project successfully created.' ]
      id: id
    , 200
  .fail (error) ->
    errors.send error, res
  .done()

# UPDATE project by ID
exports.update = (req, res) ->

  check.permissions req, 2
  .then () ->
    validate.update req
  .then (sanitized) ->
    model.update sanitized
  .then () ->
    res.send
      success: true
      messages: [ 'Project successfully updated.' ]
    , 200
  .fail (error) ->
    errors.send error, res
  .done()

# DELETE project by ID
exports.delete = (req, res) ->

  check.permissions req, 3
  .then () ->
    model.delete
      id: req.params.id
  .then (response) ->
    res.send
      success: true
      messages: [ 'Project successfully deleted.' ]
  .fail (error) ->
    errors.send error, res
  .done()