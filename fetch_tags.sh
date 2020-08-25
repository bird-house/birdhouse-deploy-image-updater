#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
# 50 - dockerhub pull error
# 51 - no valid docker image tag
###

DOCKER_HUB_REPO="birdhouse/finch"

DATA_DIR="data"


# get latest image tag from dockerhub
mkdir -p data
NAME=${DOCKER_HUB_REPO/\//_}
NEW_FILENAME=$NAME.new
NEW_FILEPATH=$DATA_DIR/$NEW_FILENAME
LATEST_TAG="latest"     # dummy one, to get replaced during API call. Needs to be more specific than 'latest'

while [ "$LATEST_TAG" == "latest" ]
do 
    LATEST_TAG=$(wget -q https://registry.hub.docker.com/v2/repositories/$DOCKER_HUB_REPO/tags -O- | jq '.results[0].name' | tr -d \")
done

if [ "$LATEST_TAG" == "" ]; then
    echo "[INFO] No valid tag found."
    exit 51
fi

echo $LATEST_TAG > $NEW_FILEPATH


# make sure data is persisted to file
if [ ! -f "$NEW_FILEPATH" ]; then
    echo "[WARNING] Error when pulling DockerHub data. Exiting."
    exit 50
fi


# diff
OLD_FILENAME=$NAME.old
OLD_FILEPATH=$DATA_DIR/$OLD_FILENAME

if [ -f "$OLD_FILEPATH" ] && [ -f "$NEW_FILEPATH" ]; then
    diff $OLD_FILEPATH $NEW_FILEPATH

    # get the latest tag ()


    # rotate historical files
    rm $OLD_FILEPATH
    mv $NEW_FILEPATH $OLD_FILEPATH
else
    echo "[INFO] No old file found to compare with. Skipping diff."
fi


# launch pr_script with params