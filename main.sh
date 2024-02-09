#!/bin/bash

## 
# https://github.com/nwtgck/piping-server/tree/develop
# Secret Sharing for Piping Server
##

## Setup
set -euo pipefail

## Setup Variable
DIR_OF_THAT_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

function generate_secret(){
    secret_length=$1
    secret_type=$2
    char_set=""
    if [[ $secret_type == *"l"* ]]; then
        char_set="${char_set}abcdefghijklmnopqrstuvwxyz"
    fi
    if [[ $secret_type == *"u"* ]]; then
        char_set="${char_set}ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    fi
    if [[ $secret_type == *"n"* ]]; then
        char_set="${char_set}0123456789"
    fi
    if [[ $secret_type == *"s"* ]]; then
        char_set="${char_set}!@#$%^&*_-+="
    fi
    secret=""
    for i in $(seq 1 $secret_length)
    do
        secret+=${char_set:RANDOM%${#char_set}:1}
    done
    echo $secret
}

function generate_secret_on_server(){
    piping_server_url=$1
    secret=$2
    RANDOM_UUID=$(uuidgen)
    curl -s -X POST -d "$secret" -m 60 "$piping_server_url/$RANDOM_UUID" > /dev/null 2>&1 & \
        log_success "Secret created successfully"
    log "Your secret is: $piping_server_url/$RANDOM_UUID"
    log "You can access with curl too:"
    log "curl -s $piping_server_url/$RANDOM_UUID"
    log "You can share this link with anyone, the person have 60 seconds to see the secret"
    log "The secret will be available on your local clipboard"
    # Use pbcopy on MacOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo $secret | pbcopy
    fi
    # Use xclip on Linux
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo $secret | xclip -selection clipboard
    fi
}

## Verify Dependencies

# Verify OS Linux or MacOS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    log_success "OS: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    log_success "OS: MacOS"
else
    log_error "OS not supported"
    exit 1
fi

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

# Check if "pbcopy" exists (Only MacOS)
if [[ "$OSTYPE" == "darwin"* ]] && ! type pbcopy > /dev/null 2>&1; then
    log_error "pbcopy command is required. Please install pbcopy."
    exit 1
fi

# Check if xclip exists (Only Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]] && ! type xclip > /dev/null 2>&1; then
    log_error "xclip command is required. Please install xclip."
    exit 1
fi

# Check if config.yaml exists
if [ ! -e $DIR_OF_THAT_FILE/config.yaml ]; then
    setup
fi

# Begin
VERSION=$(cat $DIR_OF_THAT_FILE/version)
log "Starting a Secret Sharing for Piping Server v$VERSION"

# Read config.yaml
log "Reading config.yaml"
piping_server_url=$(yq '.piping_server_url' $DIR_OF_THAT_FILE/config.yaml)
log_success "piping_server_url: $piping_server_url"

# Test if the server is a piping server
test_is_a_piping_server $piping_server_url

# Create a Menu
log "Select an option:"
log "1) Share a Secret"
log "2) Generate and Share a Secret"
log "0) Exit"
read option

# Create a Secret
if [ "$option" = "1" ]; then
    log "What is the secret? (Press enter to use default)"
    log "Default: Hello, World!"
    read secret
    # Check if secret is empty
    if [ -z "$secret" ]; then
        secret="Hello, World!"
    fi
    # Make a post with the secret and a timeout of 60 seconds in background
    log "Making a secret"
    generate_secret_on_server $piping_server_url $secret
    exit 0
elif [ "$option" = "2" ]; then
    RANDOM_UUID=$(uuidgen)
    log "How many characters do you want in the secret? (Press enter to use default)"
    log "Default: 16"
    read secret_length

    # Check if secret_length is empty
    if [ -z "$secret_length" ]; then
        secret_length=16
    fi

    log "What type of characters do you want in the secret? (Press enter to use default)"
    log "Default: luns"
    log "l: lowercase"
    log "u: uppercase"
    log "n: numbers"
    log "s: symbols"
    read secret_type

    # Check if secret_type is empty
    if [ -z "$secret_type" ]; then
        secret_type="luns"
    fi

    # Check if secret_type is valid
    if [[ ! $secret_type =~ ^[luns]+$ ]]; then
        log_error "Invalid secret type"
        exit 1
    fi
    
    # Generate a secret
    log "Generating a secret"
    secret=$(generate_secret $secret_length $secret_type)
    
    # Generate a secret on server
    generate_secret_on_server $piping_server_url $secret
else
    log "Bye!"
    exit 0
fi

    

