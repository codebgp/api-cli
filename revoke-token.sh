#!/bin/bash

# This script logins a user and returns an access token.
#
# Use the following environment variables and arguments to run this script:
#
# CODEBGP_AUTH_DOMAIN: Auth0 domain to call
# CODEBGP_AUTH_CLIENT_ID: ClientID of Auth0 application
# First argument: the refresh token to revoke

curl -sS --request POST \
    --url "https://$CODEBGP_AUTH_DOMAIN/oauth/revoke" \
    --header 'content-type: application/x-www-form-urlencoded' \
    --data "client_id=$CODEBGP_AUTH_CLIENT_ID" \
    --data "token=$1"
