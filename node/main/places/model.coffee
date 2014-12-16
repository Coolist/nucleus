# Load Node modules
Q = require 'q'

# Load custom modules
check = require '../authentication/check'
db = require '../mongodb/connect.coffee'
db.places = db.db.collection 'places'

# Helpers
errors = require '../helpers/errors.coffee'

# Find a place
exports.readOne = (params) ->
  db.places.findOne
    _id: params.id
  .then (object) ->
    if object
      ret =
        id: object._id
        name: object.name
    else
      throw new Error errors.build 'A place with that ID was not found.', 404
    return ret

# Find all places
exports.read = (params) ->
  check.request params.token
  .then (account) ->

    places = account.places.map (item) ->
      return item.place

    db.places.find
      _id:
        $in: places
    .toArray()
  .then (object) ->
    ret = []

    for item in object
      ret.push
        id: item._id
        name: item.name

    return ret

# Create new place
exports.create = (params) ->
  account = {}

  check.request params.token
  .then (a) ->
    account = a

    db.places.insert
      _id: db.id()
      name: params.name
  .then (object) ->
    db.accounts.update
      _id: account.id
    ,
      $push:
        places:
          place: object._id
          role: 'owner'

    return object
  .then (object) ->
    return object._id
  .fail (error) ->
    new Error errors.build 'Invalid authentication request token.', 401

# Update a place
exports.update = (params) ->
  db.places.update
    _id: params.id
  ,
    { $set: params.update }
  .then (res) ->
    if res.ok
      return true
    else
      throw new Error errors.build 'A place with that ID was not found.', 404

# Delete a place
exports.delete = (params) ->

  # TODO: Remove accesses

  db.places.findOne
    _id: params.id
  .then (object) ->
    if object
      db.places.remove
        _id: params.id
      return true
    else
      throw new Error errors.build 'A place with that ID was not found.', 404
    return ret