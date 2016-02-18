
class RestController
  constructor: ({@restService}) ->

  triggerByName: (request, response) =>
    {meshbluAuth, body} = request
    {responseId} = request.query
    {triggerName} = request.params
    responseBaseUri = request.header('X-RESPONSE-BASE-URI') ? 'https://rest.octoblu.com'
    @restService.triggerByName {meshbluAuth,triggerName,responseId,responseBaseUri}, body, (error, result) =>
      return response.status(error.code || 500).send error: error.message if error?
      response.status(result.code).send result.data

  triggerById: (request, response) =>
    {meshbluAuth, body} = request
    {flowId, triggerId} = request.params
    {responseId,type} = request.query
    responseBaseUri = request.header('X-RESPONSE-BASE-URI') ? 'https://rest.octoblu.com'
    @restService.triggerById {meshbluAuth,flowId,triggerId,responseId,responseBaseUri,type}, body, (error, result) =>
      return response.status(error.code || 500).send error: error.message if error?
      response.status(result.code).send result.data

  respond: (request, response) =>
    {body} = request
    {responseId} = request.params
    {code,type} = request.query
    @restService.respond {responseId,code,type}, body, (error, result) =>
      return response.status(error.code || 500).send error: error.message if error?
      response.status(result.code).send result.data

module.exports = RestController
