#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# no REQUIRED_ENV_VARS

# vars
CONFIG_FILEPATH='config.json'


# iterate through the images in config file
IMAGE_COUNT=$(cat $CONFIG_FILEPATH  | jq '.images | length')
IMAGE_INDEX=0

for ((n=0; n<$IMAGE_COUNT; n++))
do
    CURRENT_IMAGE=$(cat $CONFIG_FILEPATH | jq '.images['$n']')
    DOCKER_HUB_REPO=$(echo $CURRENT_IMAGE | jq '.dockerhub_repo_name' | tr -d '\"')

    # start fetch_tags
    DOCKER_HUB_REPO=$DOCKER_HUB_REPO ./fetch_tags.sh
done