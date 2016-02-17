RestController = require './controllers/rest-controller'
meshbluAuth    = require 'express-meshblu-auth'

class Router
  constructor: ({@restService,@meshbluConfig}) ->

  route: (app) =>
    restController = new RestController {@restService}
    app.post '/flows/:flowId/triggers/:triggerId', meshbluAuth(@meshbluConfig), restController.triggerById
    app.post '/flows/triggers/:triggerName', meshbluAuth(@meshbluConfig), restController.triggerByName
    app.post '/respond/:responseId', restController.respond

    app.get '/flows/:flowId/triggers/:triggerId', (request, response) ->
      response.status(405).send('Method Not Allowed: POST required')

    app.get '/flows/triggers/:triggerName', (request, response) ->
      response.status(405).send('Method Not Allowed: POST required')

    app.get '/respond/:responseId', (request, response) ->
      response.status(405).send('Method Not Allowed: POST required')

module.exports = Router
