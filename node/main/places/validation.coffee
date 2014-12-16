# Load modules
validate = require 'validator'

# Load helpers
errors = require '../helpers/errors.coffee'

# POST
exports.post = (req) ->

  sanitized =
    name: req.body.name
    token: req.query.token

  failed = []

  failed.push 'Place name is required.' if not sanitized.name?

  if failed.length > 0
    throw new Error errors.build failed
    return false
  
  return sanitized

# UPDATE
exports.update = (req) ->

  sanitized =
    id: req.params.id
    update: {}

  sanitized.update.name = req.body.name if req.body.name?
  
  return sanitized