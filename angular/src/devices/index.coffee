# Common
common = [
 require('../common/places/directive.coffee').name
]

# Experiments module
devices = angular.module 'nucleus.devices', common

# Styles
require './style.scss'

devices.controller 'devicesCtrl', require './controller'
devices.factory 'devicesResource', require './resource.coffee'

module.exports = devices