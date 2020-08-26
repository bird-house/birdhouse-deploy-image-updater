#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# no REQUIRED_ENV_VARS

# vars
CONFIG_FILEPATH='config.json'


# set global variables, to be used accross the script call stack
export REPO_URL=$(cat $CONFIG_FILEPATH | jq '.project.url' | tr -d '\"')
export PROJECT_NAME=${REPO_URL##*/}

# iterate through the images in config file
IMAGE_COUNT=$(cat $CONFIG_FILEPATH  | jq '.images | length')
IMAGE_INDEX=0

for ((n=0; n<$IMAGE_COUNT; n++))
do
    CURRENT_IMAGE=$(cat $CONFIG_FILEPATH | jq '.images['$n']')
    IMAGE_ID=$(echo $CURRENT_IMAGE | jq '.id' | tr -d '\"')
    DOCKER_HUB_REPO=$(echo $CURRENT_IMAGE | jq '.dockerhub_repo_name' | tr -d '\"')
    TAG_FILTER=$(echo $CURRENT_IMAGE | jq '.tag_filter' | tr -d '\"')

    # start fetch_tags
    IMAGE_ID=$IMAGE_ID DOCKER_HUB_REPO=$DOCKER_HUB_REPO TAG_FILTER=$TAG_FILTER ./fetch_tags.sh
done