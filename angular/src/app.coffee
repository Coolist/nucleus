# Angular Common
require 'bower/angular'
require 'bower/angular-route'
require 'bower/angular-resource'
require 'bower/ngstorage'

# Styles
require './styles.scss'

# Init app
components = [
  require './common/authentication'
  require './common/accesses'
  require './account'
  require './places'
  require './spaces'
]

dependencies = [
  'ngRoute',
  'ngResource'
  'ngStorage'
]

# Add defined compentents to dependencies
for component in components
  dependencies.push component.name

app = angular.module 'nucleus', dependencies

# Routes
app.config ($routeProvider) ->
  $routeProvider
    .when '/account/login',
      controller: 'accountCtrl'
      templateUrl: 'account/login/view.html'
    .when '/account/signup',
      controller: 'accountCtrl'
      templateUrl: 'account/signup/view.html'
    .when '/places',
      controller: 'placesCtrl'
      templateUrl: 'places/view.html'
    .when '/places/:placeId',
      controller: 'spacesCtrl'
      templateUrl: 'spaces/view.html'
    .otherwise
      redirectTo: '/places'