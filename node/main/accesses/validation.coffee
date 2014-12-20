# Load modules
validate = require 'validator'

# Load helpers
errors = require '../helpers/errors.coffee'

# GET
exports.get = (req) ->

  sanitized =
    placeId: req.params.placeId
  
  return sanitized

# POST
exports.post = (req) ->

  sanitized =
    email: req.body.email
    role: req.body.role
    placeId: req.params.placeId

  failed = []

  failed.push 'Email is required.' if not sanitized.email?
  failed.push 'Email is invalid.' if not validate.isEmail sanitized.email
  failed.push 'Role name is invalid. It must be owner, editor, or viewer.' if not (sanitized.role is 'owner' or sanitized.role is 'editor' or sanitized.role is 'viewer')

  if failed.length > 0
    throw new Error errors.build failed
    return false
  
  return sanitized

# UPDATE
exports.update = (req) ->

  sanitized =
    id: req.params.userId
    role: req.body.role
    placeId: req.params.placeId
    token: req.query.token

  failed = []

  failed.push 'User ID is required.' if not sanitized.id?
  failed.push 'User ID is invalid.' if sanitized.id.length isnt 24
  failed.push 'Place ID is required.' if not sanitized.placeId?
  failed.push 'Role name is invalid. It must be owner, editor, or viewer.' if not (sanitized.role is 'owner' or sanitized.role is 'editor' or sanitized.role is 'viewer')

  if failed.length > 0
    throw new Error errors.build failed
    return false
  
  return sanitized

# DELETE
exports.delete = (req) ->

  sanitized =
    id: req.params.userId
    placeId: req.params.placeId
    token: req.query.token

  failed = []

  failed.push 'User ID is required.' if not sanitized.id?
  failed.push 'User ID is invalid.' if sanitized.id.length isnt 24
  failed.push 'Place ID is required.' if not sanitized.placeId?

  if failed.length > 0
    throw new Error errors.build failed
    return false
  
  return sanitized