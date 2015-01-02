# Load Node modules
Q = require 'q'

# Load custom modules
db = require '../mongodb/connect.coffee'
db.places = db.db.collection 'places'
db.spaces = db.db.collection 'spaces'

# Helpers
errors = require '../helpers/errors.coffee'

# Find a space
exports.readOne = (params) ->
  db.spaces.findOne
    _id: params.id
    place: params.placeId
  .then (object) ->
    if object
      ret =
        id: object._id
        name: object.name
    else
      throw new Error errors.build 'A space with that ID was not found.', 404
    return ret

# Find all spaces
exports.read = (params) ->
  db.spaces.find
    place: params.placeId
  .toArray()
  .then (object) ->
    ret = []

    for item in object
      ret.push
        id: item._id
        name: item.name

    return ret

# Create new space
exports.create = (params) ->
  spaceId = db.id()

  db.places.findOne
    _id: params.placeId
  .then (object) ->
    if not object
      throw new Error errors.build 'A place with that ID was not found.', 404
  .then () ->
    db.spaces.insert
      _id: spaceId
      place: params.placeId
      name: params.name
  .then (object) ->
    return object._id

# Update a space
exports.update = (params) ->
  db.spaces.update
    _id: params.id
    place: params.placeId
  ,
    { $set: params.update }
  .then (res) ->
    if res.ok
      return true
    else
      throw new Error errors.build 'A space with that ID was not found.', 404

# Delete a space
exports.delete = (params) ->
  db.spaces.findOne
    _id: params.id
    place: params.placeId
  .then (object) ->
    if object
      db.spaces.remove
        _id: params.id
      return true
    else
      throw new Error errors.build 'A space with that ID was not found.', 404
    return ret