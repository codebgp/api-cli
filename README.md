# CLI
CLI access to bgp-data is described below.

The scripts in this directory perform HTTP requests to CodeBGP Authentication service and the GraphQL API.

## Variables

1. `CODEBGP_AUTH_DOMAIN` and `CODEBGP_AUTH_CLIENT_ID` are needed for all commands interacting with the Authentication service (#1, #5, #7),
because they identify the client account and are pre-configured on the Authentication service. They can be defined as
environment variables:
```
declare -x CODEBGP_AUTH_CLIENT_ID=`auth-client-id` \
    CODEBGP_AUTH_DOMAIN=login.codebgp.com
```

2. `--username`, `--password` and `tenant-id` are required for the initial authentication (#1). `--jwt_audience` is implicitly propagated to tokens on refresh and it receives a default value when omitted.

3. `CODEBGP_ACCESS_TOKEN`  `CODEBGP_REFRESH_TOKEN` are state variables, updated by authentication commands and used to keep the state of the currently used tokens. `CODEBGP_ENDPOINT` is extracted from the `CODEBGP_ACCESS_TOKEN` payload custom claim to dynamically set the API endpoint from the access token.

Note: List all CODEBGP variables using: `set | grep CODEBGP`

## Commands
The commands below depend on `jq` for JSON processing, but any similar tool can be used.

1. Fetch the `CODEBGP_ACCESS_TOKEN` and `CODEBGP_REFRESH_TOKEN`:
```
temp=$(./get-token.sh --username=`username` --password=`password` --tenant=`tenant-id`) \
    && CODEBGP_ACCESS_TOKEN=$(echo $temp | jq -r .access_token) \
    && CODEBGP_REFRESH_TOKEN=$(echo $temp | jq -r .refresh_token)
```

2. Extract the `CODEBGP_ENDPOINT` from the access token:
```
CODEBGP_ENDPOINT=$(CODEBGP_ACCESS_TOKEN=$CODEBGP_ACCESS_TOKEN ./get-endpoint.sh)
```

3. Use the `CODEBGP_ACCESS_TOKEN` and `CODEBGP_ENDPOINT` to perform GraphQL queries from file:
```
CODEBGP_ACCESS_TOKEN=$CODEBGP_ACCESS_TOKEN \
     CODEBGP_ENDPOINT=$CODEBGP_ENDPOINT \
    ./query.sh ./sample_query.json | jq .
```

4. Use the `CODEBGP_ACCESS_TOKEN` and `CODEBGP_ENDPOINT` to perform GraphQL queries from query string:
```
CODEBGP_ACCESS_TOKEN=$CODEBGP_ACCESS_TOKEN \
    CODEBGP_ENDPOINT=$CODEBGP_ENDPOINT \
    ./query.sh "{\"query\": \"query { prefixes { network } }\"}" | jq .
```

5. Refresh the `CODEBGP_ACCESS_TOKEN` using the `CODEBGP_REFRESH_TOKEN`:
```
temp=$(./refresh-token.sh $CODEBGP_REFRESH_TOKEN) \
    && CODEBGP_ACCESS_TOKEN=$(echo $temp | jq -r .access_token)
```

6. If Refresh Token rotation is enabled, also get the `CODEBGP_REFRESH_TOKEN` from refresh token output:
```
CODEBGP_REFRESH_TOKEN=$(echo $temp | jq -r .refresh_token)
```

7. Revoke the `CODEBGP_REFRESH_TOKEN`:
```
./revoke-token.sh $CODEBGP_REFRESH_TOKEN
```

## Flow

1. In authentication step, user credentials should be used for fetching access and refresh tokens (#1). The user credentials SHOULD NOT be available in the following steps of the flow, to minimise risk of credentials leak. Only the access and refresh tokens are needed in the following requests for accessing the GraphQL API and refreshing the tokens. Following, the API endpoint will be extracted from the token (#2).

2. In normal operation of a client script, the access token will be used for performing GraphQL API queries (#3 or #4). This step can repeat multiple times until step 5 is needed.

3. When the GraphQL API query returns an authorization error (`jq -e '.errors[0].extensions | select (.code == "invalid-jwt")'`), the access token should be refreshed (#5). Optionally, based on Auth0 configuration, the refresh command will also refresh the refresh token (#6), to minimise the risk from refresh token leak. Steps 3 and 4 can repeat multiple times.

4. In a teardown step, revoke the refresh token (#7). This will minimise the risk from refresh token leak.
