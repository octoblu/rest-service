# Octoblu Rest Service
Service to list and activate Octoblu triggers and wait for a response.

## Supported Auth Methods

* cookies: `request.cookies.meshblu_auth_uuid` and `request.cookies.meshblu_auth_token`
* headers: `request.cookies.meshblu_auth_uuid` and `request.cookies.meshblu_auth_token`
* basic: `Authorization: Basic c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`
* bearer: `Authorization: Bearer c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`

## Activate Trigger Example:

```
curl -X POST https://rest.octoblu.com/flows/:flowId/triggers/:id -H 'meshblu_auth_uuid: uuid' -H 'meshblu_auth_token: token'
```

## Respond tp Trigger Example:

```
curl -X POST https://rest.octoblu.com/requests/:requestId
```
