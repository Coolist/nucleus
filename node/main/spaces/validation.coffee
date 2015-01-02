# Load modules
validate = require 'validator'

# Load helpers
errors = require '../helpers/errors.coffee'

# POST
exports.post = (req) ->

  sanitized =
    name: req.body.name
    placeId: req.params.placeId

  failed = []

  failed.push 'Space name is required.' if not sanitized.name?

  if failed.length > 0
    throw new Error errors.build failed
    return false
  
  return sanitized

# UPDATE
exports.update = (req) ->

  sanitized =
    id: req.params.id
    placeId: req.params.placeId
    update: {}

  sanitized.update.name = req.body.name if req.body.name?
  
  return sanitized