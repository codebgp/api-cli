#!/bin/bash

# This script retrieves the backend endpoint from the JWT token.
#
# Use the following env variables and arguments to run this script:
#
# CODEBGP_ACCESS_TOKEN: the access token
jwt_cli="./bin/jwt-cli"
downloadJWTCLI() {
    if [[ -f $jwt_cli ]]; then
        return 1
    fi

    bin=./bin
    [[ ! -d $bin ]] && mkdir -p $bin

    VERSION=4.0.0
    PLATFORM=linux
    case $(uname) in
        Darwin)
            PLATFORM=macOS
            ;;
    esac

    curl -Ls https://github.com/mike-engel/jwt-cli/releases/download/$VERSION/jwt-$PLATFORM.tar.gz --output - | gunzip -c | tar xopf - -O >$jwt_cli && chmod +x $jwt_cli
    return 0
}

downloadJWTCLI
$jwt_cli decode -j $CODEBGP_ACCESS_TOKEN | jq -r '.payload."https://tenant.codebgp.com/claims".api'
