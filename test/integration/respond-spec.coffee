_          = require 'lodash'
request    = require 'request'
shmock     = require '@octoblu/shmock'
Server     = require '../../src/server'
redis      = require 'redis'
RedisNS    = require '@octoblu/redis-ns'
JobManager = require 'meshblu-core-job-manager'
uuid       = require 'uuid'

describe 'Respond', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d
    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true
      meshbluConfig: meshbluConfig
      jobTimeoutSeconds: 1
      namespace:   'rest:test'
      jobLogQueue: 'rest:job-log'
      jobLogRedisUri: 'redis://localhost:6379'

    @server = new Server serverOptions

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  beforeEach ->
    @redis = _.bindAll new RedisNS 'rest:test', redis.createClient()
    @jobManager = new JobManager client: @redis, timeoutSeconds: 1

  describe 'POST /respond/:responseId', ->
    beforeEach (done) ->
      options =
        uri: '/respond/my-response-id'
        baseUrl: "http://localhost:#{@serverPort}"
        json:
          name: 'Freedom'
        qs:
          code: 201

      request.post options, (error, @response, @body) =>
        throw error if error?
        @jobManager.getResponse 'response', 'my-response-id', (error, @result) =>
          done error

    it 'should respond with 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should have a body', ->
      expect(@body).to.deep.equal success: true

    it 'should have the correct data', ->
      expect(JSON.parse @result.rawData).to.deep.equal name: 'Freedom'

    it 'should have the correct code', ->
      expect(@result.metadata.code).to.equal 201
