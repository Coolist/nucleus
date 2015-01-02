api = require '../common/api'

devicesResource = ($resource) ->
  $resource api.config.endpoint + '/places/:placeId/devices/:deviceId/:state',
    placeId: '@placeId'
    deviceId: '@deviceId'
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
    updateState:
      method: 'PUT'
      params:
        state: 'states'
    delete:
      method: 'DELETE'


module.exports = [
  '$resource'
  devicesResource
]