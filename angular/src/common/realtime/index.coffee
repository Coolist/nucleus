realtime = angular.module 'nucleus.common.realtime', []

realtime.factory 'realtimeFactory', require './factory'

module.exports = realtime