# Places module
places = angular.module 'nucleus.places', []

# Styles
require './style.scss'

places.controller 'placesCtrl', require './controller'
places.factory 'placesResource', require '../common/places/resource'

module.exports = places