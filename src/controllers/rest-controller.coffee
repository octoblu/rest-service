
class RestController
  constructor: ({@restService}) ->

  triggerByName: (request, response) =>
    {meshbluAuth, body} = request
    {responseId} = request.query
    {triggerName} = request.params
    @restService.triggerByName {meshbluAuth,triggerName,responseId}, body, (error, result) =>
      return response.status(error.code || 500).send error: error if error?
      response.status(result.code).send result.data

  triggerById: (request, response) =>
    {meshbluAuth, body} = request
    {flowId, triggerId} = request.params
    {responseId} = request.query
    @restService.triggerByName {meshbluAuth,flowId,triggerId,responseId}, body, (error, result) =>
      return response.status(error.code || 500).send error: error if error?
      response.status(result.code).send result.data

  respond: (request, response) =>
    {body} = request
    {responseId} = request.params
    {code} = request.query
    @restService.respond {responseId,code}, body, (error, result) =>
      return response.status(error.code || 500).send error: error if error?
      response.status(result.code).send result.data

module.exports = RestController
