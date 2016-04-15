RestController = require './controllers/rest-controller'
MeshbluAuth    = require 'express-meshblu-auth'

class Router
  constructor: ({meshbluConfig, restService}) ->
    @meshbluAuth =  new MeshbluAuth meshbluConfig
    @restController = new RestController {meshbluConfig, restService}

  route: (app) =>
    app.use @meshbluAuth.retrieve
    app.post '/flows/:flowId/triggers/:triggerId', @restController.triggerById
    app.post '/flows/triggers/:triggerName', @meshbluAuth.gateway, @restController.triggerByName
    app.post '/respond/:responseId', @restController.respond

    app.get '/flows/:flowId/triggers/:triggerId', (request, response) ->
      response.status(405).send('Method Not Allowed: POST required')

    app.get '/flows/triggers/:triggerName', (request, response) ->
      response.status(405).send('Method Not Allowed: POST required')

    app.get '/respond/:responseId', (request, response) ->
      response.status(405).send('Method Not Allowed: POST required')

module.exports = Router
