#!/bin/bash

# This script logins a user and returns an access token.
#
# Use the following environment variables and arguments to run this script:
#
# CODEBGP_AUTH_DOMAIN: Auth0 domain to call
# CODEBGP_AUTH_CLIENT_ID: ClientID of Auth0 application
# First argument: the refresh token

curl -sS --request POST \
    --url "https://$CODEBGP_AUTH_DOMAIN/oauth/token" \
    --header 'content-type: application/x-www-form-urlencoded' \
    --data grant_type=refresh_token \
    --data "client_id=$CODEBGP_AUTH_CLIENT_ID" \
    --data "refresh_token=$1"
