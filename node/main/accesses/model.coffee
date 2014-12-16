# Load Node modules
Q = require 'q'
objectID = require('promised-mongo').ObjectId

# Load custom modules
db = require '../mongodb/connect.coffee'
db.accounts = db.db.collection 'accounts'
db.places = db.db.collection 'places'
check = require '../authentication/check'

# Helpers
errors = require '../helpers/errors.coffee'

# Update access to a place
exports.get = (params) ->

  db.accounts.find
    places:
      $elemMatch:
        place: params.placeId
  ,
    'name': 1
    'email': 1
    'places.$': 1
  .toArray()
  .then (accounts) ->
    ret = []

    for account in accounts
      ret.push
        id: account._id
        name: account.name
        email: account.email
        role: account.places[0].role

    return ret

# Create new access to a place
exports.create = (params) ->
  db.accounts.findOne
    email: params.email
  .then (account) ->

    if account?
      for place in account.places
        if place.place is params.placeId
          throw new Error errors.build 'A role for this place has already been assigned to this user.', 400
    return account
  .then (account) ->
    if account?
      db.accounts.update
        email: params.email
      ,
        $push:
          places:
            place: params.placeId
            role: params.role
    else
      db.accounts.insert
        registered: false
        email: params.email
        password: ''
        name: 'Invited'
        places: [{ place: params.placeId, role: params.role }]

    # TODO: Send invite email here

  .then () ->
    return true

# Update access to a place
exports.update = (params) ->

  db.accounts.findOne
    _id: new objectID params.id
    places:
      $elemMatch:
        place: params.placeId
  .then (account) ->

    if not account?
      throw new Error errors.build 'This user does not exist or has not yet been granted permission to this place.', 404
    
    check.request params.token
    .then (me) ->
      if me.places?
        myPermission = check.getPermissions me.places, params.placeId
        theirPermission = check.getPermissions account.places, params.placeId
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
        places:
          $elemMatch:
            place: params.placeId
      ,
        $set:
          'places.$.role': params.role

  .then (res) ->
    if res
      return true

# Remove access to a place
exports.delete = (params) ->

  db.accounts.findOne
    _id: new objectID params.id
    places:
      $elemMatch:
        place: params.placeId
  .then (account) ->

    if not account?
      throw new Error errors.build 'This user does not exist or has not yet been granted permission to this place.', 404
    
    check.request params.token
    .then (me) ->
      if me.places?
        myPermission = check.getPermissions me.places, params.placeId
        theirPermission = check.getPermissions account.places, params.placeId
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
          places:
            place: params.placeId

  .then (res) ->
    if res
      return true