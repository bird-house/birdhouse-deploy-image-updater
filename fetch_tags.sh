#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
# 50 - dockerhub pull error
# 51 - no valid docker image tag
# 52 - no old tag file found
###

REQUIRED_ENV_VARS='
    DOCKER_HUB_REPO
'

# args parsing
for env_var in $REQUIRED_ENV_VARS
do
    if [[ ! -v "${env_var}" ]]; then
        echo "[ERROR] Missing ${env_var} environment variable. Exiting."
        exit 1
    fi
done

# DOCKER_HUB_REPO="birdhouse/finch"
DATA_DIR="data"


# get latest image tag from dockerhub
mkdir -p data
NAME=${DOCKER_HUB_REPO/\//_}
NEW_FILENAME=$NAME.new
NEW_FILEPATH=$DATA_DIR/$NEW_FILENAME
LATEST_TAG="latest"     # dummy one, to get replaced during API call. Needs to be more specific than 'latest'

TAG_INDEX=0

while [ "$LATEST_TAG" == "latest" ]
do
    # assumption that results are always in the same order, most recent first
    LATEST_TAG=$(wget -q https://registry.hub.docker.com/v2/repositories/$DOCKER_HUB_REPO/tags -O- | jq '.results['$TAG_INDEX'].name' | tr -d \")
    TAG_INDEX=$TAG_INDEX+1
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


# diff with old file
OLD_FILENAME=$NAME.old
OLD_FILEPATH=$DATA_DIR/$OLD_FILENAME

NEW_TAG_FOUND=false

if [ -f "$OLD_FILEPATH" ] && [ -f "$NEW_FILEPATH" ]; then
    DIFF=$(diff $OLD_FILEPATH $NEW_FILEPATH)

    # TODO : uncomment after testing
    # if [ "$DIFF"  == "" ]; then
    #     echo "[INFO] No new tag found. Exiting"
    #     rm $NEW_FILEPATH
    #     exit 0
    # fi

    NEW_TAG_FOUND=true
else
    echo "[INFO] No old file found to compare with. Skipping diff."
fi

# rotate historical files
mv $NEW_FILEPATH $OLD_FILEPATH

# launch pr_script with params
if [[ $NEW_TAG_FOUND = true ]]; then
    ./pr_script.sh
fi