#!/bin/bash

## 
# https://github.com/nwtgck/piping-server/tree/develop
# Secret Sharing for Piping Server
##

## Setup
set -euo pipefail

## Functions
function log(){
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1"
}

function log_success(){
    log "✅ $1"
}

function log_error(){
    log "❌ $1"
}

function setup() {
    # Create config.yaml
    log "Create config.yaml"
    log "Whats is your piping server URL? (Press enter to use default)"
    log "Default: https://ping.enderson.dev"
    read piping_server_url
    if [ -z "$piping_server_url" ]; then
        piping_server_url="https://ping.enderson.dev"
    fi
    echo "piping_server_url: $piping_server_url" > config.yaml
    log_success "config.yaml created"
}

function test_is_a_piping_server(){
    server_to_test=$1
    # Check if the server is a piping server
    log "Check if the server is a piping server"
    RANDOM_UUID=$(uuidgen)
    RANDOM_TEXT="Hello, World! $RANDOM_UUID"
    # Execute a POST with timeout 10 seconds in background
    # The GET response should be the same as the POST
    curl -s -X POST -d "$RANDOM_TEXT" -m 10 "$server_to_test/$RANDOM_UUID" > /dev/null 2>&1 & \
        if curl -s -m 10 "$server_to_test/$RANDOM_UUID" | grep "$RANDOM_TEXT" > /dev/null 2>&1; then
            log_success "The server is a piping server"
        else
            log_error "The server is not a piping server"
            exit 1
        fi
}


## Verify Dependencies

# Check if "curl" exists
if ! type curl > /dev/null 2>&1; then
    log_error "curl command is required. Please install curl."
    exit 1
fi

# Check if "yq" exists
if ! type yq > /dev/null 2>&1; then
    log_error "yq command is required. Please install yq."
    exit 1
fi

# Check if "uuidgen" exists
if ! type uuidgen > /dev/null 2>&1; then
    log_error "uuidgen command is required. Please install uuidgen."
    exit 1
fi

# Check if config.yaml exists
if [ ! -e config.yaml ]; then
    setup
fi

# Begin
VERSION=$(cat version)
log "Starting a Secret Sharing for Piping Server v$VERSION"

# Read config.yaml
log "Reading config.yaml"
piping_server_url=$(yq '.piping_server_url' config.yaml)
log_success "piping_server_url: $piping_server_url"

# Test if the server is a piping server
test_is_a_piping_server $piping_server_url

# Create a Menu
log "Select an option:"
log "1) Create a Secret"
log "2) Put this script in your path"
log "0) Exit"
read option

# Create a Secret
if [ "$option" = "1" ]; then
    RANDOM_UUID=$(uuidgen)
    log "What is the secret? (Press enter to use default)"
    log "Default: Hello, World!"
    read secret
    if [ -z "$secret" ]; then
        secret="Hello, World!"
    fi
    # Make a post with the secret and a timeout of 60 seconds in background
    log "Making a secret"
    curl -s -X POST -d "$secret" -m 60 "$piping_server_url/$RANDOM_UUID" > /dev/null 2>&1 & \
        log_success "Secret created successfully"
    log "Your secret is: $piping_server_url/$RANDOM_UUID"
    log "You can access with curl too:"
    log "curl -s $piping_server_url/$RANDOM_UUID"
    log "You can share this link with anyone, the person have 60 seconds to see the secret"
    exit 0
else
    log "Bye!"
    exit 0
fi

    

