# Load Node modules
Q = require 'q'

# Load custom modules
check = require '../authentication/check'
db = require '../mongodb/connect.coffee'
db.projects = db.db.collection 'projects'

# Helpers
errors = require '../helpers/errors.coffee'

# Find a project
exports.readOne = (params) ->
  db.projects.findOne
    _id: params.id
  .then (object) ->
    if object
      ret =
        id: object._id
        name: object.name
    else
      throw new Error errors.build 'A project with that ID was not found.', 404
    return ret

# Find all projects
exports.read = (params) ->
  check.request params.token
  .then (account) ->

    projects = account.projects.map (item) ->
      return item.project

    db.projects.find
      _id:
        $in: projects
    .toArray()
  .then (object) ->
    ret = []

    for item in object
      ret.push
        id: item._id
        name: item.name

    return ret

# Create new project
exports.create = (params) ->
  account = {}

  check.request params.token
  .then (a) ->
    account = a

    db.projects.insert
      _id: db.id()
      name: params.name
  .then (object) ->
    db.accounts.update
      _id: account.id
    ,
      $push:
        projects:
          project: object._id
          role: 'owner'

    return object
  .then (object) ->
    return object._id
  .fail (error) ->
    new Error errors.build 'Invalid authentication request token.', 401

# Update a project
exports.update = (params) ->
  db.projects.update
    _id: params.id
  ,
    { $set: params.update }
  .then (res) ->
    if res.ok
      return true
    else
      throw new Error errors.build 'A project with that ID was not found.', 404

# Delete a project
exports.delete = (params) ->

  # TODO: Remove accesses

  db.projects.findOne
    _id: params.id
  .then (object) ->
    if object
      db.projects.remove
        _id: params.id
      return true
    else
      throw new Error errors.build 'A project with that ID was not found.', 404
    return ret