#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
# 100 - new tag found, pr_script triggered
###

# no REQUIRED_ENV_VARS

# clean past log
export DATA_DIR="data"
rm -f $DATA_DIR/last-update-result.log

# config file
if [[ ! -v CONFIG_FILE ]]; then
    echo "[ERROR] NO CONFIG FILE SPECIFIED."
    exit 1
fi

if [ ! -f $CONFIG_FILE ]; then
    echo "[INFO] Config file not existing. Exiting."
    exit 1
fi

echo "[INFO] USING CONFIG FILE ${CONFIG_FILE}"

# env file
if [[ ! -v ENV_FILE ]]; then
    echo "[ERROR] NO ENV FILE SPECIFIED."
    exit 1
fi

if [ ! -f $ENV_FILE ]; then
    echo "[INFO] Env file not existing. Exiting."
    exit 1
fi

source $ENV_FILE
echo "[INFO] USING ENVIRONMENT FILE ${ENV_FILE}"


# set global variables, to be used accross the script call stack
export REPO_URL=$(cat $CONFIG_FILE | jq '.project.url' | tr -d '\"')
export PROJECT_ORG_REPO=$(echo $REPO_URL | cut -d/ -f4-)
export PROJECT_NAME=${REPO_URL##*/}
export ONLY_UPDATE_TAGS_HISTORY=${ONLY_UPDATE_TAGS_HISTORY}
export GITHUB_TOKEN=$GITHUB_TOKEN
export EXIT_BEFORE_PR=$EXIT_BEFORE_PR
export DRY_RUN=$DRY_RUN

# iterate through the images in config file
IMAGE_COUNT=$(cat $CONFIG_FILE | jq '.images | length')
IMAGE_INDEX=0

for ((n=0; n<$IMAGE_COUNT; n++))
do
    CURRENT_IMAGE=$(cat $CONFIG_FILE | jq '.images['$n']')
    IMAGE_ID=$(echo $CURRENT_IMAGE | jq '.id' | tr -d '\"')
    DOCKERHUB_REPO=$(echo $CURRENT_IMAGE | jq '.dockerhub_repo_name' | tr -d '\"')
    TAG_FILTER=$(echo $CURRENT_IMAGE | jq '.tag_filter' | tr -d '\"')
    BUMP_TAG=$(echo $CURRENT_IMAGE | jq '.bump_tag')
    BUMP_TAG=${BUMP_TAG:1:-1}    # remove first and last string quotes
    BUMP_FILE=$(echo $CURRENT_IMAGE | jq '.bump_file' | tr -d '\"')

    # start fetch_tags
    IMAGE_ID=$IMAGE_ID DOCKERHUB_REPO=$DOCKERHUB_REPO TAG_FILTER=$TAG_FILTER BUMP_TAG=$BUMP_TAG BUMP_FILE=$BUMP_FILE ./fetch_tags.sh
    
    if [[ $? -eq 100 ]]; then
        exit 100
    fi
done

exit 0
