# Common
common = [
  require('../common/places/directive.coffee').name
]

# Experiments module
spaces = angular.module 'nucleus.spaces', common

# Styles
require './style.scss'

spaces.controller 'spacesCtrl', require './controller'
spaces.controller 'spacesNewCtrl', require './new/controller'
spaces.factory 'spacesResource', require './resource.coffee'

module.exports = spaces