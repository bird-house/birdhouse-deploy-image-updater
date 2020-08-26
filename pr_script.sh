#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# Sample environment variables
# REPO_URL=https://github.com/bird-house/birdhouse-deploy
# PROJECT_NAME=birdhouse-deploy
# IMAGE_ID="weaver-worker"
# BUMP_TAG="FINCH_IMAGE"
# BUMP_TAG_VALUE="0.5.3"
# BUMP_FILE="birdhouse/default.env"
# GITHUB_USER=""
# GITHUB_PASSWORD=""

REQUIRED_ENV_VARS='
    REPO_URL
    PROJECT_NAME
    IMAGE_ID
    BUMP_TAG
    BUMP_TAG_VALUE
    BUMP_FILE
    GITHUB_USER
    GITHUB_PASSWORD
'

# args parsing
for env_var in $REQUIRED_ENV_VARS
do
    if [[ ! -v "${env_var}" ]]; then
        echo "[ERROR] [$0] Missing ${env_var} environment variable. Exiting."
        exit 1
    fi
done

echo "[STEP] [$0] [$PROJECT_NAME] Fetch tags"

COMMIT_MESSAGE="bump ${IMAGE_ID} ${IMAGE_TAG}"
BRANCH_NAME="bump_${IMAGE_ID}_${IMAGE_TAG}"


# prepare repo
git clone $REPO_URL         # TODO : other working_dir
cd $PROJECT_NAME
git checkout -b $BRANCH_NAME

# bumpversion
./bump_version.sh

# push
git add -A
git commit -m $COMMIT_MESSAGE
git push

# PR
hub pull-request -m $COMMIT_MESSAGE