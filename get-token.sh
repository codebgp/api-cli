#!/bin/bash

# This script logins a user and returns an access token.
#
# Use the following env variables and arguments to run this script:
#
# CODEBGP_AUTH_DOMAIN: Auth0 domain to call
# CODEBGP_AUTH_CLIENT_ID: ClientID of Auth0 application
# username: username to authenticate
# password: password to authenticate
# tenant: the tenant database to authenticate against
# jwt_audience(optional): API audience that the requested access token is for

while [ $# -gt 0 ]; do
    case "$1" in
        --username=*)
            username="${1#*=}"
            ;;
        --password=*)
            password="${1#*=}"
            ;;
        --tenant=*)
            tenant="${1#*=}"
            ;;
        --jwt_audience=*)
            jwt_audience="${1#*=}"
            ;;
        *)
            printf "***************************\n"
            printf "* Error: Invalid argument.*\n"
            printf "***************************\n"
            exit 1
            ;;
    esac
    shift
done

if [[ -z $jwt_audience ]]; then
    jwt_audience=https://codebgp.com
fi

curl -sS --request POST \
    --url "https://$CODEBGP_AUTH_DOMAIN/oauth/token" \
    --header 'content-type: application/x-www-form-urlencoded' \
    --data "grant_type=http://auth0.com/oauth/grant-type/password-realm" \
    --data "client_id=$CODEBGP_AUTH_CLIENT_ID" \
    --data "username=$username" \
    --data "password=$password" \
    --data "realm=$(echo $tenant'-db')" \
    --data "audience=$jwt_audience" \
    --data "scope=offline_access"
