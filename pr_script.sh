#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# Sample environment variables
# REPO_URL=https://github.com/bird-house/birdhouse-deploy
# PROJECT_NAME=birdhouse-deploy
# DOCKERHUB_REPO="pavics/weaver"
# IMAGE_ID="weaver-worker"
# BUMP_TAG="WEAVER_WORKER_IMAGE"
# BUMP_TAG_VALUE="1.13.2-worker"
# BUMP_FILE="birdhouse/default.env"
# GITHUB_USER=""
# GITHUB_PASSWORD=""

REQUIRED_ENV_VARS='
    REPO_URL
    PROJECT_NAME
    DOCKERHUB_REPO
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

WORKING_DIR="working_dir"

echo "[STEP] [$0] [$PROJECT_NAME] Fetch tags"

COMMIT_MESSAGE="bump ${IMAGE_ID} to ${BUMP_TAG_VALUE}"
BRANCH_NAME="bump_${IMAGE_ID}_to_${BUMP_TAG_VALUE}"


# prepare repo
mkdir -p $WORKING_DIR
# rm -rf $WORKING_DIR/$PROJECT_NAME
cd $WORKING_DIR

if [[ ! -d "$PROJECT_NAME" ]]
then
    echo "[INFO] Not existing project directory, cloning"
    git clone $REPO_URL
    cd $PROJECT_NAME
else
    echo "[INFO] Existing project directory, cleaning"
    cd $PROJECT_NAME
    git clean -fd
    git reset --hard origin
    git checkout master
    git pull
    git branch -D $BRANCH_NAME     # TODO : to avoid already existing branch error. Handle error instead
fi

git checkout -b $BRANCH_NAME

# bumpversion
DOCKERHUB_REPO=$DOCKERHUB_REPO BUMP_TAG=$BUMP_TAG BUMP_TAG_VALUE=$BUMP_TAG_VALUE BUMP_FILE=$BUMP_FILE ../../bump_version.sh

# to track last diff result
git diff &> ../../last-diff-result.log

# push
git add -A
git commit -m "$COMMIT_MESSAGE"
# git push

# PR
# hub pull-request -m $COMMIT_MESSAGE



## TODO remove
# curl \
#   -X POST \
#   -H "Accept: application/vnd.github.v3+json" \
#   localhost:6000/repos/bird-house/birdhouse-deploy/pulls \
#   -d '{"title":"title","head":"head","base":"base"}'