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
  require './projects'
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
      controller: 'projectsCtrl'
      templateUrl: 'projects/view.html'
    .when '/places/:placeId',
      templateUrl: 'projects/view.html'
    .otherwise
      redirectTo: '/places'


###.when '/places/:projectId',
  controller: 'experimentsCtrl'
  templateUrl: 'experiments/view.html'
###