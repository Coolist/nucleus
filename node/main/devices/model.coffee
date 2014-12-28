# Load Node modules
Q = require 'q'

# Load custom modules
db = require '../mongodb/connect.coffee'
db.places = db.db.collection 'places'
db.devices = db.db.collection 'devices'

# Helpers
errors = require '../helpers/errors.coffee'

# Find a device
exports.readOne = (params) ->
  db.devices.findOne
    _id: params.id
  .then (object) ->
    if object
      ret =
        id: object._id
        name: object.name
        place: object.place
        service: object.service
        properties: object.properties
        values: object.values
    else
      throw new Error errors.build 'A device with that ID was not found.', 404
    return ret

# Find all devices
exports.read = (params) ->
  db.devices.find
    place: params.placeId
  .toArray()
  .then (object) ->
    ret = []

    for item in object
      ret.push
        id: item._id
        name: item.name
        place: item.place
        service: item.service
        properties: item.properties
        values: item.values

    return ret

# Create new device
###
exports.create = (params) ->
  deviceId = db.id()

  db.places.findOne
    _id: params.placeId
  .then (object) ->
    if not object
      throw new Error errors.build 'A place with that ID was not found.', 404
  .then () ->
    db.devices.insert
      _id: deviceId
      place: params.placeId
      name: params.name
  .then (object) ->
    return object._id
###

# Update a device
exports.update = (params) ->
  db.devices.update
    _id: params.id
  ,
    { $set: params.update }
  .then (res) ->
    if res.ok
      return true
    else
      throw new Error errors.build 'A device with that ID was not found.', 404

# Delete a device
exports.delete = (params) ->
  db.devices.findOne
    _id: params.id
  .then (object) ->
    if object
      db.devices.remove
        _id: params.id
      return true
    else
      throw new Error errors.build 'A device with that ID was not found.', 404
    return ret