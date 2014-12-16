module.exports = (app, router) ->

  # Load Modules
  bodyParser = require 'body-parser'

  # Load Controllers
  authentication = require './main/authentication/controller'
  accesses = require './main/accesses/controller'
  project = require './main/projects/controller'

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

  # Projects
  router.get pre + 'projects/:projectId/users', accesses.get
  router.post pre + 'projects/:projectId/users', accesses.post
  router.put pre + 'projects/:projectId/users/:userId', accesses.update
  router.delete pre + 'projects/:projectId/users/:userId', accesses.delete

  # Project access
  router.get pre + 'projects/:id', project.getOne
  router.get pre + 'projects', project.get
  router.post pre + 'projects', project.post
  router.put pre + 'projects/:id', project.update
  router.delete pre + 'projects/:id', project.delete

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