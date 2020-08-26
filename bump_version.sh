#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# Sample environment variables
# IMAGE_VERSION_LOCATOR="FINCH_IMAGE"
# BUMP_TAG="0.5.3"
# BUMP_FILE="birdhouse/default.env"

REQUIRED_ENV_VARS='
    IMAGE_VERSION_LOCATOR
    BUMP_TAG
    BUMP_FILE
'

# args parsing
for env_var in $REQUIRED_ENV_VARS
do
    if [[ ! -v "${env_var}" ]]; then
        echo "[ERROR] [$0] Missing ${env_var} environment variable. Exiting."
        exit 1
    fi
done

# TODO implement logic