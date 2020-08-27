#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# Sample environment variables
# DOCKERHUB_REPO="pavics/weaver"
# BUMP_TAG="WEAVER_WORKER_IMAGE"
# BUMP_TAG_VALUE="1.13.2-worker"
# BUMP_FILE="birdhouse/default.env"

REQUIRED_ENV_VARS='
    DOCKERHUB_REPO
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


NEW_IMAGE_TAG_VALUE=$DOCKERHUB_REPO":"$BUMP_TAG_VALUE
NEW_IMAGE_TAG_DECLARATION="export "$BUMP_TAG"=\""$NEW_IMAGE_TAG_VALUE"\""

sed -i "/.*$BUMP_TAG.*/c $NEW_IMAGE_TAG_DECLARATION" $BUMP_FILE
