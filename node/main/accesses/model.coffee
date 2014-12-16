# Load Node modules
Q = require 'q'
objectID = require('promised-mongo').ObjectId

# Load custom modules
db = require '../mongodb/connect.coffee'
db.accounts = db.db.collection 'accounts'
db.projects = db.db.collection 'projects'
check = require '../authentication/check'

# Helpers
errors = require '../helpers/errors.coffee'

# Update access to a project
exports.get = (params) ->

  db.accounts.find
    projects:
      $elemMatch:
        project: params.projectId
  ,
    'name': 1
    'email': 1
    'projects.$': 1
  .toArray()
  .then (accounts) ->
    ret = []

    for account in accounts
      ret.push
        id: account._id
        name: account.name
        email: account.email
        role: account.projects[0].role

    return ret

# Create new access to a project
exports.create = (params) ->
  db.accounts.findOne
    email: params.email
  .then (account) ->

    if account?
      for project in account.projects
        if project.project is params.projectId
          throw new Error errors.build 'A role for this project has already been assigned to this user.', 400
    return account
  .then (account) ->
    if account?
      db.accounts.update
        email: params.email
      ,
        $push:
          projects:
            project: params.projectId
            role: params.role
    else
      db.accounts.insert
        registered: false
        email: params.email
        password: ''
        name: 'Invited'
        projects: [{ project: params.projectId, role: params.role }]

    # TODO: Send invite email here

  .then () ->
    return true

# Update access to a project
exports.update = (params) ->

  db.accounts.findOne
    _id: new objectID params.id
    projects:
      $elemMatch:
        project: params.projectId
  .then (account) ->

    if not account?
      throw new Error errors.build 'This user does not exist or has not yet been granted permission to this project.', 404
    
    check.request params.token
    .then (me) ->
      if me.projects?
        myPermission = check.getPermissions me.projects, params.projectId
        theirPermission = check.getPermissions account.projects, params.projectId
      else
        throw new Error errors.build 'You do not have the correct permissions to access this resource.', 401

      if myPermission isnt 3 and theirPermission is 3
        throw new Error errors.build 'You must have owner permissions to assign a role to this user.', 401

      if myPermission isnt 3 and params.role is 'owner'
        throw new Error errors.build 'You must have owner permissions to assign owner role to this user.', 401

      if myPermission < 2
        throw new Error errors.build 'You must have owner or editor permissions to assign a role to this user.', 401

    .then () ->
      db.accounts.update
        _id: new objectID params.id
        projects:
          $elemMatch:
            project: params.projectId
      ,
        $set:
          'projects.$.role': params.role

  .then (res) ->
    if res
      return true

# Remove access to a project
exports.delete = (params) ->

  db.accounts.findOne
    _id: new objectID params.id
    projects:
      $elemMatch:
        project: params.projectId
  .then (account) ->

    if not account?
      throw new Error errors.build 'This user does not exist or has not yet been granted permission to this project.', 404
    
    check.request params.token
    .then (me) ->
      if me.projects?
        myPermission = check.getPermissions me.projects, params.projectId
        theirPermission = check.getPermissions account.projects, params.projectId
      else
        throw new Error errors.build 'You do not have the correct permissions to access this resource.', 401

      if myPermission isnt 3 and theirPermission is 3
        throw new Error errors.build 'You must have owner permissions to remove this user\'s access.', 401

      if myPermission isnt 3 and params.role is 'owner'
        throw new Error errors.build 'You must have owner permissions to remove access from this user with an owner role.', 401

      if myPermission < 2
        throw new Error errors.build 'You must have owner or editor permissions to remove this user\'s access.', 401

    .then () ->
      db.accounts.update
        _id: new objectID params.id
      ,
        $pull:
          projects:
            project: params.projectId

  .then (res) ->
    if res
      return true