#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# no REQUIRED_ENV_VARS

# vars
CONFIG_FILEPATH='config.json'

# seed .env if we are not in test mode
if [[ -z "${TEST_ENV_CONFIG}" ]]; then
    source .env
else
    echo "[INFO] TEST CONFIG SEEDED"
fi


# set global variables, to be used accross the script call stack
export REPO_URL=$(cat $CONFIG_FILEPATH | jq '.project.url' | tr -d '\"')
export PROJECT_NAME=${REPO_URL##*/}
export ONLY_UPDATE_TAGS_HISTORY=${ONLY_UPDATE_TAGS_HISTORY}
export GITHUB_USER=$GITHUB_USER
export GITHUB_PASSWORD=$GITHUB_PASSWORD

# iterate through the images in config file
IMAGE_COUNT=$(cat $CONFIG_FILEPATH  | jq '.images | length')
IMAGE_INDEX=0

for ((n=0; n<$IMAGE_COUNT; n++))
do
    CURRENT_IMAGE=$(cat $CONFIG_FILEPATH | jq '.images['$n']')
    IMAGE_ID=$(echo $CURRENT_IMAGE | jq '.id' | tr -d '\"')
    DOCKERHUB_REPO=$(echo $CURRENT_IMAGE | jq '.dockerhub_repo_name' | tr -d '\"')
    TAG_FILTER=$(echo $CURRENT_IMAGE | jq '.tag_filter' | tr -d '\"')
    BUMP_TAG=$(echo $CURRENT_IMAGE | jq '.bump_tag' | tr -d '\"')
    BUMP_FILE=$(cat $CONFIG_FILEPATH | jq '.project.bump_file' | tr -d '\"')

    # start fetch_tags
    IMAGE_ID=$IMAGE_ID DOCKERHUB_REPO=$DOCKERHUB_REPO TAG_FILTER=$TAG_FILTER BUMP_TAG=$BUMP_TAG BUMP_FILE=$BUMP_FILE ./fetch_tags.sh
    
    if [[ $? -eq 100 ]]; then
        echo "[INFO] Created PR for [${IMAGE_ID}]. Exiting."
        exit 0
    fi
done