Meshblu      = require 'meshblu-http'
TriggerModel = require './trigger-model'
_            = require 'lodash'
uuid         = require 'uuid'
debug        = require('debug')('triggers-service:trigger-controller')

class TriggerController
  constructor: (@meshbluOptions={}) ->
    @triggerModel = new TriggerModel()
    @pending = {}

  respond: (request, response) =>
    console.log 'looking for:', request.params.requestId
    pending = @pending[request.params.requestId]
    return response.status(404).send() unless pending?

    console.log pending, pending?
    delete @pending[request.params.requestId]
    pending.response.status(200).send(request.body)
    response.status(200).send()

  trigger: (request, response) =>
    {flowId, triggerId} = request.params

    defaultAuth =
      uuid: process.env.REST_SERVICE_UUID
      token: process.env.REST_SERVICE_TOKEN

    meshbluConfig = _.extend {}, defaultAuth, request.meshbluAuth, @meshbluOptions
    meshblu = new Meshblu meshbluConfig
    message =
      devices: [flowId]
      topic: 'triggers-service'
      payload:
        from: triggerId
        params: request.body
        requestId: uuid.v1()

    debug 'sending message', message

    console.log 'setting:', message.payload.requestId
    @pending[message.payload.requestId] = request: request, response: response
    meshblu.message message, (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?

  getTriggers: (request, response) =>
    meshbluConfig = _.extend request.meshbluAuth, @meshbluOptions
    meshblu = new Meshblu meshbluConfig
    meshblu.devices type: 'octoblu:flow', (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?

      triggers = @triggerModel.parseTriggersFromDevices body.devices
      return response.status(200).json(triggers)

  getMyTriggers: (request, response) =>
    meshbluAuth = request.meshbluAuth ? {}
    meshbluConfig = _.extend meshbluAuth, @meshbluOptions
    meshblu = new Meshblu meshbluConfig
    meshblu.devices type: 'octoblu:flow', owner: meshbluConfig.uuid, (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?

      triggers = @triggerModel.parseTriggersFromDevices body.devices
      return response.status(200).json(triggers)

module.exports = TriggerController
