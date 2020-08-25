#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###


# vars

CONFIG_FILEPATH='config.json'


# iterate through the images in config file
IMAGE_INDEX=0

CURRENT_IMAGE=$(cat $CONFIG_FILEPATH | jq '.images['$IMAGE_INDEX']')
DOCKER_HUB_REPO=$(echo $CURRENT_IMAGE | jq '.dockerhub_repo_name')


# !! TODO : change call structure, to manage env vars in better way


# start fetch_tags
./fetch_tags.sh