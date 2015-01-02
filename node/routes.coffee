module.exports = (app, router) ->

  # Load Modules
  bodyParser = require 'body-parser'

  # Load Controllers
  authentication = require './main/authentication/controller'
  accesses = require './main/accesses/controller'
  deviceAuth = require './main/device-auth/controller'
  place = require './main/places/controller'
  space = require './main/spaces/controller'
  device = require './main/devices/controller'

  pre = '/api/1/'

  # ---- API ---- #

  # Accounts
  router.post pre + 'authentication', authentication.post
  router.get pre + 'authentication/access', authentication.getAccess
  router.get pre + 'authentication/request', authentication.getRequest
  router.put pre + 'authentication', authentication.update
  router.delete pre + 'authentication', authentication.delete
  router.post pre + 'authentication/reset/request', authentication.postResetRequest
  router.post pre + 'authentication/reset', authentication.postReset

  # Place access
  router.get pre + 'places/:placeId/users', accesses.get
  router.post pre + 'places/:placeId/users', accesses.post
  router.put pre + 'places/:placeId/users/:userId', accesses.update
  router.delete pre + 'places/:placeId/users/:userId', accesses.delete

  # Device auth
  router.get pre + 'device-auth/services/:service', deviceAuth.getRedirect
  router.get pre + 'device-auth/services/:service/activate', deviceAuth.getActivate
  router.post pre + 'device-auth/services/:service/places/:placeId', deviceAuth.postService

  # Places
  router.get pre + 'places/:id', place.getOne
  router.get pre + 'places', place.get
  router.post pre + 'places', place.post
  router.put pre + 'places/:id', place.update
  router.delete pre + 'places/:id', place.delete

  # Spaces
  router.get pre + 'places/:placeId/spaces/:id', space.getOne
  router.get pre + 'places/:placeId/spaces', space.get
  router.post pre + 'places/:placeId/spaces', space.post
  router.put pre + 'places/:placeId/spaces/:id', space.update
  router.delete pre + 'places/:placeId/spaces/:id', space.delete

  # Devices
  router.get pre + 'places/:placeId/devices/:id', device.getOne
  router.get pre + 'places/:placeId/devices', device.get
  router.put pre + 'places/:placeId/devices/:id', device.update
  router.put pre + 'places/:placeId/devices/:id/states', device.updateState
  router.delete pre + 'places/:placeId/devices/:id', device.delete

  # Allow all origins for API
  app.use (req, res, next) ->

    res.setHeader('Access-Control-Allow-Origin', '*')
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE')
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type')

    next()
  app.use bodyParser()
  app.use '/', router

  # 404 Fallback
  app.use (req, res) ->
    res.json 404,
      success: false
      messages: ['There is no request at this location.']

  # Application errors
  app.use (err, req, res, next) ->
    console.error err.stack

    status = err.status || 500
    res.json status,
      success: false
      messages: ['An internal server error has occured. This has been logged in our servers.']