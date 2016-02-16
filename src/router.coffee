RestController = require './controllers/rest-controller'
meshbluAuth    = require 'express-meshblu-auth'

class Router
  constructor: ({@restService,@meshbluConfig}) ->

  route: (app) =>
    restController = new RestController {@restService}
    app.use '/flows', meshbluAuth(@meshbluConfig)

    app.post '/flows/:flowId/triggers/:triggerId', restController.triggerById
    app.post '/flows/triggers', restController.triggerByName
    app.post '/respond/:responseId', restController.respond

    app.get '/flows/:flowId/triggers/:triggerId', (request, response) ->
      response.status(405).send('Method Not Allowed: POST required')

    app.get '/respond/:responseId', (request, response) ->
      response.status(405).send('Method Not Allowed: POST required')

module.exports = Router
