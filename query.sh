#!/bin/bash

# This script sends query to GraphQL endpoint and returns the response.
#
# Use the following environment variables and arguments to run this script:
#
# CODEBGP_ACCESS_TOKEN: the access token
# CODEBGP_ENDPOINT: the endpoint (URL) where the API is available
# First argument: the path to a file or the content to be sent in request body

if [[ -z $CODEBGP_ACCESS_TOKEN ]]; then
    echo "no access token provided. Exiting..."
    exit 1
fi

if [[ -z $CODEBGP_ENDPOINT ]]; then
    CODEBGP_ENDPOINT="localhost"
fi

GQL_API_URL="https://$CODEBGP_ENDPOINT/graphql"

if [[ -z $1 ]]; then
    echo "no query provided"
    exit 1
fi

if [[ -f $1 ]]; then
    curl -sSL --insecure -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $CODEBGP_ACCESS_TOKEN" $GQL_API_URL --data @"$1"
else
    curl -sSL --insecure -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $CODEBGP_ACCESS_TOKEN" $GQL_API_URL --data-raw "$1"
fi
