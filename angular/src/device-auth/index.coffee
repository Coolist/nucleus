# Device auth module
deviceAuth = angular.module 'nucleus.deviceAuth', []

# Styles
require './style.scss'

deviceAuth.controller 'deviceAuthCtrl', require './controller'
deviceAuth.factory 'deviceAuthResource', require '../common/deviceAuth/resource'

module.exports = deviceAuth