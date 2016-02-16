request    = require 'request'
shmock     = require '@octoblu/shmock'
Server     = require '../../src/server'
redis      = require 'fakeredis'
RedisNS    = require '@octoblu/redis-ns'
JobManager = require 'meshblu-core-job-manager'
uuid       = require 'uuid'

describe 'Respond', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    @redisKey = uuid.v1()
    client = new RedisNS 'rest-test', redis.createClient @redisKey

    jobManager = new JobManager client: client, timeoutSeconds: 1
    @server = new Server serverOptions, {meshbluConfig, jobManager}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

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
        done error

    it 'should respond with 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should have a body', ->
      expect(@body).to.deep.equal success: true

    describe 'it should create the request', ->
      beforeEach (done)->
        client = new RedisNS 'rest-test', redis.createClient @redisKey

        jobManager = new JobManager client: client, timeoutSeconds: 1

        jobManager.getResponse 'response', 'my-response-id', (error, @result) =>
          done error

      it 'should have the correct data', ->
        expect(JSON.parse @result.rawData).to.deep.equal name: 'Freedom'

      it 'should have the correct code', ->
        expect(@result.metadata.code).to.equal 201
