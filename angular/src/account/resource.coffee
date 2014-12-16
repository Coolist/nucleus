api = require '../common/api'

accountResource = ($http) ->
  baseUrl: api.config.endpoint + '/authentication'
  signup: (params, res) ->
    self = @
    $http.post @baseUrl, params
    .success (data, status) ->
      console.log 'Success!', data, status
      self.login params, (data) ->
        res(data)
    .error (data) ->
      alert 'Could not sign you up: ' + data.messages.join ' '
    # TO DO: Handle error
  login: (params, res) ->
    $http
      method: 'GET'
      url: @baseUrl + '/access'
      params:
        email: params.email
        password: params.password
    .success (data) ->
      res(data)
    .error (data) ->
      alert 'Could not log you in: ' + data.messages.join ' '

module.exports = [
  '$http',
  accountResource
]