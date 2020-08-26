#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# Sample environment variables
# BUMP_TAG="WEAVER_WORKER_IMAGE"
# BUMP_TAG_VALUE="1.13.2-worker"
# BUMP_FILE="birdhouse/default.env"

REQUIRED_ENV_VARS='
    BUMP_TAG
    BUMP_TAG_VALUE
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