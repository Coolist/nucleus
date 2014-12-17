# Account module
account = angular.module 'nucleus.account', []

# Styles
require './style.scss'

account.controller 'accountCtrl', require './controller'
account.factory 'accountResource', require './resource'

module.exports = account