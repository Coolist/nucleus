api = require '../api'

accessResource = ($resource) ->
  return $resource api.config.endpoint + '/projects/:projectId/users/:userId',
    projectId: '@projectId',
    userId: '@userId'
    auth: true
  ,
    query:
      method: 'GET'
      isArray: true
    post:
      method: 'POST'
    get:
      method: 'GET'
    update:
      method: 'PUT'
    delete:
      method: 'DELETE'


module.exports = [
  '$resource'
  accessResource
]