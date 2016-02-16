_            = require 'lodash'
NodeUUID     = require 'uuid'

class RestService
  constructor: ({@jobManager}) ->

  triggerByName: ({meshbluAuth,triggerName,responseId}, data, callback) =>
    responseId ?= NodeUUID.v4()
    message =
      metadata:
        auth: meshbluAuth
        jobType: 'triggerByName'
        responseId: responseId
        triggerName: triggerName
      data: data

    @jobManager.do 'request', 'response', message, (error, result) =>
      return callback @_createError 500, error.message if error?
      return callback @_createError 408, 'Request Timeout' unless result?
      callback null, code: result.metadata?.code, data: JSON.parse result.rawData

  triggerById: ({meshbluAuth,flowId,triggerId,responseId}, data, callback) =>
    responseId ?= NodeUUID.v4()
    message =
      metadata:
        auth: meshbluAuth
        jobType: 'triggerById'
        responseId: responseId
        triggerId: triggerId
        flowId: flowId
      data: data

    @jobManager.do 'request', 'response', message, (error, result) =>
      return callback @_createError 500, error.message if error?
      return callback @_createError 408, 'Request Timeout' unless result?
      callback null, code: result.metadata?.code, data: JSON.parse result.rawData

  respond: ({code,responseId}, data, callback) =>
    code = parseInt code if code?
    code ?= 200
    message =
      metadata: {code, responseId}
      data: data

    @jobManager.createResponse 'response', message, (error) =>
      return callback @_createError 500, error.message if error?
      callback null, code: 200, data: success: true

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = RestService
