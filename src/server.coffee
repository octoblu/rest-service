_                  = require 'lodash'
colors             = require 'colors'
cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
debug              = require('debug')('rest-service:server')
redis              = require 'redis'
RedisNS            = require '@octoblu/redis-ns'
{Pool}             = require 'generic-pool'
PooledJobManager   = require 'meshblu-core-pooled-job-manager'
JobLogger          = require 'job-logger'
RestService        = require './services/rest-service'
Router             = require './router'

class Server
  constructor: (options)->
    {@disableLogging, @port} = options
    {@meshbluConfig} = options
    {@connectionPoolMaxConnections, @redisUri, @namespace, @jobTimeoutSeconds} = options
    {@jobLogRedisUri, @jobLogQueue} = options
    @panic 'missing @jobLogQueue', 2 unless @jobLogQueue?
    @panic 'missing @jobLogRedisUri', 2 unless @jobLogRedisUri?
    @panic 'missing @namespace', 2 unless @namespace?

  panic: (message, exitCode, error) =>
    error ?= new Error('generic error')
    console.error colors.red message
    console.error error?.stack
    process.exit exitCode

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use meshbluHealthcheck()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'

    app.options '*', cors()

    jobLogger = new JobLogger
      jobLogQueue: @jobLogQueue
      indexPrefix: 'metric:rest-service'
      type: 'rest-service:request'
      client: redis.createClient(@jobLogRedisUri)

    connectionPool = @_createConnectionPool()
    jobManager = new PooledJobManager
      timeoutSeconds: @jobTimeoutSeconds
      pool: connectionPool
      jobLogger: jobLogger

    restService = new RestService {jobManager}
    router = new Router {@meshbluConfig, restService}

    router.route app

    @server = app.listen @port, callback

  _createConnectionPool: =>
    connectionPool = new Pool
      max: @connectionPoolMaxConnections
      min: 0
      returnToHead: true # sets connection pool to stack instead of queue behavior
      create: (callback) =>
        client = _.bindAll new RedisNS @namespace, redis.createClient(@redisUri)

        client.on 'end', ->
          client.hasError = new Error 'ended'

        client.on 'error', (error) ->
          client.hasError = error
          callback error if callback?

        client.once 'ready', ->
          callback null, client
          callback = null

      destroy: (client) => client.end true
      validate: (client) => !client.hasError?

    return connectionPool

  stop: (callback) =>
    @server.close callback

module.exports = Server
