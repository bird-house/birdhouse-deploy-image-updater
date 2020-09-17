#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
# 50 - dockerhub pull error
# 51 - no valid docker image tag
# 52 - no old tag file found
# 53 - max tag count iteration reached
# 100 - new tag found, pr_script triggered
###

# Sample envionment variables
# IMAGE_ID="weaver-worker"
# DOCKERHUB_REPO="pavics/weaver"
# TAG_FILTER="^[0-9]+(\\.[0-9]+)*$"
# BUMP_TAG="WEAVER_WORKER_IMAGE"
# BUMP_FILE="birdhouse/default.env"

REQUIRED_ENV_VARS='
    IMAGE_ID
    DOCKERHUB_REPO
    TAG_FILTER
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

echo "[STEP] [$0] [$IMAGE_ID] Fetch tags"

DATA_DIR="data"


# get latest image tag from dockerhub
mkdir -p $DATA_DIR
NAME=${DOCKERHUB_REPO//\//_}_$IMAGE_ID
NEW_FILENAME=$NAME.new
NEW_FILEPATH=$DATA_DIR/$NEW_FILENAME
DOCKERHUB_IMAGE_TAGS=$(wget -q $DOCKERHUB_IMAGE_TAGS_URL$DOCKERHUB_REPO/tags?page_size=1024 -O-)
MAX_TAG_ITERATION=$(echo $DOCKERHUB_IMAGE_TAGS | jq '.count')
TAG_INDEX=0
TAG_FILTER=${TAG_FILTER//\\\\/\\}    # replace \\ with \ in regex

while [[ ! $LATEST_TAG =~ $TAG_FILTER ]]
do
    # assumption that results are always in the same order, most recent first
    LATEST_TAG=$(echo $DOCKERHUB_IMAGE_TAGS | jq '.results['$TAG_INDEX'].name' | tr -d \")
    TAG_INDEX=$TAG_INDEX+1

    if [[ "$TAG_INDEX" -eq "$MAX_TAG_ITERATION" ]]; then
        echo "[WARNING] [$0] Reached max tag iteration count. Exiting."
        exit 53
    fi
done

if [ "$LATEST_TAG" == "" ]; then
    echo "[INFO] [$0] [$IMAGE_ID] No valid tag found. Exiting."
    exit 51
fi

echo $LATEST_TAG > $NEW_FILEPATH


# make sure data is persisted to file
if [ ! -f "$NEW_FILEPATH" ]; then
    echo "[WARNING] [$0] [$IMAGE_ID] Error when pulling DockerHub data. Exiting."
    exit 50
fi


# diff with old file
OLD_FILENAME=$NAME.old
OLD_FILEPATH=$DATA_DIR/$OLD_FILENAME

NEW_TAG_FOUND=false

if [ -f "$OLD_FILEPATH" ] && [ -f "$NEW_FILEPATH" ]; then
    if diff $OLD_FILEPATH $NEW_FILEPATH; then
        echo "[INFO] [$0] [$IMAGE_ID] No new tag found. Exiting."
        rm $NEW_FILEPATH
        exit 0
    else
        NEW_TAG_FOUND=true
    fi
else
    echo "[INFO] [$0] [$IMAGE_ID] No old file found to compare with. Skipping diff."
fi

# rotate historical files
mv $NEW_FILEPATH $OLD_FILEPATH

# useful for first time use
if [[ ! -z "${ONLY_UPDATE_TAGS_HISTORY}" ]]; then
    echo "[INFO] Tag for [$IMAGE_ID] updated and ONLY_UPDATE_TAGS_HISTORY used. Exiting."
    exit 0
fi

# launch pr_script with params
if [[ $NEW_TAG_FOUND = true ]]; then
    DOCKERHUB_REPO=$DOCKERHUB_REPO IMAGE_ID=$IMAGE_ID BUMP_TAG=$BUMP_TAG NEW_TAG_VALUE=$LATEST_TAG BUMP_FILE=$BUMP_FILE ./pr_script.sh
    
    # output to logs
    echo ${IMAGE_ID}:${LATEST_TAG} > $DATA_DIR/last-update-result.log
    git remote set-url origin https://$GITHUB_TOKEN:x-oauth-basic@github.com/$PROJECT_ORG_REPO.git
    hub pr list -f "%U" -L 1 > $DATA_DIR/last-pr-url.log
    
    if [[ -z "${EXIT_BEFORE_PR}" ]]; then
        echo "[INFO] Created PR for [${IMAGE_ID}]. Exiting."
    fi

    exit 100
fi
