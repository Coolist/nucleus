accesses = angular.module 'nucleus.common.accesses', []

accesses.service 'accessService', require './service'
accesses.factory 'accessResource', require './resource'

module.exports = accesses