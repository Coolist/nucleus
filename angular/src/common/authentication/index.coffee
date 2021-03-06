authentication = angular.module 'nucleus.common.authentication', []

authentication.factory 'authInterceptor', require './interceptor'

# Config (include http interceptor)
authentication.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'authInterceptor'
]

module.exports = authentication