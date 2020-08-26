#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

REQUIRED_ENV_VARS='
    IMAGE_VERSION_LOCATOR
    BUMP_TAG
    BUMP_FILE
'

# args parsing
for env_var in $REQUIRED_ENV_VARS
do
    if [[ ! -v "${env_var}" ]]; then
        echo "[ERROR] Missing ${env_var} environment variable. Exiting."
        exit 1
    fi
done

# TODO