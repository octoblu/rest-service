_ = require 'lodash'

class RestController
  constructor: ({@meshbluConfig, @restService}) ->

  triggerByName: (request, response) =>
    {meshbluAuth, body} = request
    {responseId,type} = request.query
    {triggerName} = request.params
    responseBaseUri = request.header('X-RESPONSE-BASE-URI') ? 'https://rest.octoblu.com'
    @restService.triggerByName {meshbluAuth,triggerName,responseId,responseBaseUri,type}, body, (error, result) =>
      return response.status(error.code || 500).send error: error.message if error?
      response.status(result.code).send result.data

  triggerById: (request, response) =>
    {meshbluAuth, body} = request
    {flowId, triggerId} = request.params
    {responseId} = request.query
    meshbluAuth = request.meshbluAuth ? @meshbluConfig
    auth = _.pick meshbluAuth, 'uuid', 'token'

    responseBaseUri = request.header('X-RESPONSE-BASE-URI') ? 'https://rest.octoblu.com'
    @restService.triggerById {auth,flowId,triggerId,responseId,responseBaseUri}, body, (error, result) =>
      return response.status(error.code || 500).send error: error.message if error?
      response.status(result.code).send result.data

  respond: (request, response) =>
    {body} = request
    {responseId} = request.params
    {code} = request.query
    @restService.respond {responseId,code}, body, (error, result) =>
      return response.status(error.code || 500).send error: error.message if error?
      response.status(result.code).send result.data

module.exports = RestController
