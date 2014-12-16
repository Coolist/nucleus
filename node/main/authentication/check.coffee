# Load Node modules
Q = require 'q'

# Load custom modules
db = require '../mongodb/connect.coffee'
db.accounts = db.db.collection 'accounts'
db.tokens = db.db.collection 'tokens'

# Helpers
errors = require '../helpers/errors.coffee'

# Convert permission name to number to compare
convertPermission = (name) ->
  if name is 'owner'
    return 3
  else if name is 'editor'
    return 2
  else if name is 'viewer'
    return 1
  else
    return 0

# Check request token and return account
exports.request = (token) ->
  deferred = Q.defer()

  db.tokens.findOne
    token: token
  .then (object) ->
    if object? and object.type is 'request'
      db.accounts.findOne
        _id: object.account
    else
      deferred.reject new Error errors.build 'Invalid authentication request token.', 401
  .then (account) ->
    if account?
      deferred.resolve
        id: account._id
        name: account.name
        email: account.email
        places: account.places || undefined
        password: account.password
    else
      deferred.reject new Error errors.build 'Invalid authentication request token.', 401

  return deferred.promise

# Check access permissions
exports.tokenPermissions = (token, place, permission, error) ->

  return exports.request token
  .then (account) ->
    if account.places?
      for p in account.places
        if p.place is place
          role = convertPermission p.role

          if role >= permission
            return true

    throw new Error errors.build error || 'You do not have the correct permissions to access this resource.', 401

# Get permissions of a place from an array of places
exports.getPermissions = (places, placeId) ->

  for p in places
    if p.place is placeId
      return convertPermission p.role

  return 0

# Check request permissions (wrapper)
exports.permissions = (req, permission, error) ->
  deferred = Q.defer()

  if not req.query.token? or not (req.params.placeId? or req.params.id?)
    deferred.reject new Error errors.build 'Invalid authentication request token.', 401

  place = req.params.placeId || req.params.id
  
  exports.tokenPermissions req.query.token, place, permission, error
  .then (valid) ->
    deferred.resolve valid
  .fail (error) ->
    deferred.reject error

  return deferred.promise