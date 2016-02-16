cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
debug              = require('debug')('rest-service:server')
RestService        = require './services/rest-service'
Router             = require './router'

class Server
  constructor: ({@disableLogging, @port}, {@meshbluConfig,@jobManager})->

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use meshbluHealthcheck()
    app.use bodyParser.urlencoded limit: '50mb', extended : true
    app.use bodyParser.json limit : '50mb'

    app.options '*', cors()

    restService = new RestService {@jobManager}
    router = new Router {restService,@meshbluConfig}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
