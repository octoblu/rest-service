request    = require 'request'
shmock     = require '@octoblu/shmock'
Server     = require '../../src/server'
redis      = require 'fakeredis'
RedisNS    = require '@octoblu/redis-ns'
JobManager = require 'meshblu-core-job-manager'
uuid       = require 'uuid'

describe 'Trigger By Id', ->
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

  describe 'POST /flows/:flowId/triggers/:triggerId', ->
    beforeEach (done) ->
      client = new RedisNS 'rest-test', redis.createClient @redisKey

      jobManager = new JobManager client: client, timeoutSeconds: 1

      auth = new Buffer('my-uuid:my-token').toString('base64')

      @meshbluAuth = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{auth}"
        .reply 200, uuid: 'my-uuid', token: 'my-token'

      responseOptions =
        metadata:
          responseId: 'response-id'
          code: 200
        data:
          name: 'Freedom'

      jobManager.createResponse 'response', responseOptions, ->

      options =
        uri: '/flows/flow-id/triggers/trigger-id'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          user: 'my-uuid'
          pass: 'my-token'
        json:
          name: 'Freedom'
        qs:
          responseId: 'response-id'

      request.post options, (error, @response, @body) =>
        done error

    it 'should auth the device', ->
      @meshbluAuth.done()

    it 'should respond with 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should have a body', ->
      expect(@body).to.deep.equal name: 'Freedom'
