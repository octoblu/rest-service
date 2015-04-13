Meshblu      = require './meshblu'
TriggerModel = require './trigger-model'
_            = require 'lodash'

class TriggerController
  constructor: (@meshbluOptions={}) ->
    @triggerModel = new TriggerModel()

  trigger: (request, response) =>
    {flowId, triggerId} = request.params

    meshbluConfig = _.extend request.meshbluAuth, @meshbluOptions
    meshblu = new Meshblu meshbluConfig
    meshblu.trigger flowId, triggerId, (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?
      return response.status(201).json(body)

  getTriggers: (request, response) =>
    meshbluConfig = _.extend request.meshbluAuth, @meshbluOptions
    meshblu = new Meshblu meshbluConfig
    meshblu.flows (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?

      triggers = @triggerModel.parseTriggersFromDevices body.devices
      return response.status(200).json(triggers)

module.exports = TriggerController
