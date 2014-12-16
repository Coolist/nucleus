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
        projects: account.projects || undefined
        password: account.password
    else
      deferred.reject new Error errors.build 'Invalid authentication request token.', 401

  return deferred.promise

# Check access permissions
exports.tokenPermissions = (token, project, permission, error) ->

  return exports.request token
  .then (account) ->
    if account.projects?
      for p in account.projects
        if p.project is project
          role = convertPermission p.role

          if role >= permission
            return true

    throw new Error errors.build error || 'You do not have the correct permissions to access this resource.', 401

# Get permissions of a project from an array of projects
exports.getPermissions = (projects, projectId) ->

  for p in projects
    if p.project is projectId
      return convertPermission p.role

  return 0

# Check request permissions (wrapper)
exports.permissions = (req, permission, error) ->
  deferred = Q.defer()

  if not req.query.token? or not (req.params.projectId? or req.params.id?)
    deferred.reject new Error errors.build 'Invalid authentication request token.', 401

  project = req.params.projectId || req.params.id
  
  exports.tokenPermissions req.query.token, project, permission, error
  .then (valid) ->
    deferred.resolve valid
  .fail (error) ->
    deferred.reject error

  return deferred.promise