api = require '../api'

interceptor = ($q, $injector, $location, $localStorage) ->
  request: (config) ->
    http = $injector.get '$http'
    deferred = $q.defer()

    if config.params? and config.params.auth
      config.params.auth = undefined

      if $localStorage.tokenRequest? and new Date($localStorage.tokenRequest.expires).getTime() > ( Date.now() + 1000 * 60 * 5 )
        config.params.token = $localStorage.tokenRequest.token
        deferred.resolve config
      else if $localStorage.tokenAccess?
        tokenAccess = $localStorage.tokenAccess

        http
          method: 'GET'
          url: api.config.endpoint + "/authentication/request?token=#{tokenAccess}"
        .success (data, status) ->
          config.params.token = data.token

          $localStorage.tokenRequest =
            token: data.token
            expires: data.expires

          deferred.resolve config
        .error () ->
          delete $localStorage.tokenAccess
          delete $localStorage.tokenRequest
          delete $localStorage.userSettings
          $location.path 'account/login'
      else
        $location.path 'account/login'
    else
      deferred.resolve config

    return deferred.promise

  responseError: (res) ->

    if res.status is 401
      delete $localStorage.tokenRequest if $localStorage.tokenRequest?
      delete $localStorage.tokenAccess if $localStorage.tokenAccess?
      delete $localStorage.userSettings if $localStorage.userSettings?
      $location.path 'account/login'

    return $q.reject res

module.exports = [
  '$q'
  '$injector'
  '$location'
  '$localStorage'
  interceptor
]