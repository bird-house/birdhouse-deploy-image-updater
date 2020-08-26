#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

REQUIRED_ENV_VARS='
    REPO_URL
    PROJECT_NAME
    COMMIT_MESSAGE
    BRANCH_NAME
    IMAGE_VERSION_LOCATOR
    BUMP_TAG
    BUMP_FILE
'

# args parsing
for env_var in $REQUIRED_ENV_VARS
do
    if [[ ! -v "${env_var}" ]]; then
        echo "[ERROR] Missing ${env_var} environment variable. Exiting."
        exit 1
    fi
done


# # git specifics
# REPO_URL=https://github.com/bird-house/birdhouse-deploy
# PROJECT_NAME=finch
# COMMIT_MESSAGE="bump_finch_0.5.3"
# BRANCH_NAME="bump_finch_0.5.3"

# # bumpversion config
# IMAGE_VERSION_LOCATOR="FINCH_IMAGE"
# BUMP_TAG="0.5.3"
# BUMP_FILE="birdhouse/default.env"

# # hub config
# GITHUB_USER=""
# GITHUB_PASSWORD=""


# prepare repo
git clone $REPO_URL
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