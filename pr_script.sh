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
# NEW_TAG_VALUE="1.13.2-worker"
# BUMP_FILE="birdhouse/default.env"
# GITHUB_TOKEN=""

REQUIRED_ENV_VARS='
    REPO_URL
    PROJECT_NAME
    DOCKERHUB_REPO
    IMAGE_ID
    BUMP_TAG
    NEW_TAG_VALUE
    BUMP_FILE
    GITHUB_TOKEN
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

echo "[STEP] [$0] [$PROJECT_NAME] PR"

COMMIT_MESSAGE="bump \`${IMAGE_ID}\` to ${NEW_TAG_VALUE}"
BRANCH_NAME="bump_${IMAGE_ID}_to_${NEW_TAG_VALUE}"


# prepare repo
mkdir -p $WORKING_DIR
# rm -rf $WORKING_DIR/$PROJECT_NAME
cd $WORKING_DIR

if [[ ! -d "$PROJECT_NAME" ]]
then
    echo "[INFO] Not existing project directory, cloning"
    hub clone $PROJECT_ORG_REPO
    cd $PROJECT_NAME
else
    echo "[INFO] Existing project directory, cleaning"
    cd $PROJECT_NAME
    git clean -fd
    git reset --hard origin
    git checkout master
    hub pull
    git branch -D $BRANCH_NAME     # TODO : currently avoids already existing branch error. Handle error instead
fi

git checkout -b $BRANCH_NAME

# for testing purpose only, since birdhouse-deploy's default.env doesn't has WEAVER_WORKER_IMAGE variable for now
if [[ ! -z "${TEST_ENV_CONFIG}" ]] && [[ "$BUMP_TAG" == "WEAVER_WORKER_IMAGE" ]]; then
    echo "export WEAVER_WORKER_IMAGE=\"pavics/weaver:1.13.1-worker\"" >> $BUMP_FILE
fi

# bumpversion
DOCKERHUB_REPO=$DOCKERHUB_REPO BUMP_TAG=$BUMP_TAG NEW_TAG_VALUE=$NEW_TAG_VALUE BUMP_FILE=$BUMP_FILE ../../bump_version.sh

# to track last diff result
git diff &> ../../last-diff-result.log

# commit
git add -A
git commit -m "$COMMIT_MESSAGE"

# when in test mode, we can avoid to make a real PR
if [[ ! -z "${EXIT_BEFORE_PR}" ]]; then
    echo "[INFO] Exiting before PR, since EXIT_BEFORE_PR is defined. Exiting."
    exit 0
fi

# PR
git remote set-url origin https://$GITHUB_TOKEN:x-oauth-basic@github.com/$PROJECT_ORG_REPO.git
hub push origin $BRANCH_NAME
hub pull-request -m "$COMMIT_MESSAGE" -F- <<<"THIS IS THE SUBJECT
THIS IS SECOND LINE OF SUBJECT

This is the body.
This is the second line of body.

This will all be body."
hub pr list -f "%U" -L 1 > ../../$DATA_DIR/last-pr-url.log
