Meshblu      = require 'meshblu-http'
TriggerModel = require './trigger-model'
_            = require 'lodash'
uuid         = require 'uuid'
url          = require 'url'
debug        = require('debug')('rest-service:trigger-controller')

class TriggerController
  constructor: (@meshbluOptions={}) ->
    @triggerModel = new TriggerModel()
    @HOSTNAME = process.env.HOSTNAME
    @PORT = process.env.PORT
    @PROTOCOL = "http"
    @pending = {}

  respond: (request, response) =>
    debug 'looking for:', request.params.requestId
    pending = @pending[request.params.requestId]
    return response.status(404).send() unless pending?

    debug pending, pending?
    delete @pending[request.params.requestId]
    pending.response.status(200).send(request.body)
    response.status(200).send()

  trigger: (request, response) =>
    {flowId, triggerId} = request.params

    defaultAuth =
      uuid: process.env.REST_SERVICE_UUID
      token: process.env.REST_SERVICE_TOKEN

    requestId = uuid.v1()

    urlOptions =
      hostname: @HOSTNAME
      port: @PORT
      protocol: @PROTOCOL
      path: "/requests/#{requestId}"

    callbackUrl = url.format urlOptions

    meshbluConfig = _.extend {}, defaultAuth, request.meshbluAuth, @meshbluOptions
    meshblu = new Meshblu meshbluConfig
    message =
      devices: [flowId]
      topic: 'triggers-service'
      payload:
        from: triggerId
        params: request.body
        requestId: requestId
        callbackUrl: callbackUrl

    debug 'sending message', message

    debug 'setting:', message.payload.requestId
    @pending[message.payload.requestId] = request: request, response: response
    meshblu.message message, (error, body) =>
      return response.status(401).json error: 'unauthorized' if error?.message == 'unauthorized'
      return response.status(500).end() if error?

module.exports = TriggerController
