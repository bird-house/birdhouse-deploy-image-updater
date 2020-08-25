

# git specifics
REPO_URL=https://github.com/bird-house/finch
PROJECT_NAME=finch
COMMIT_MESSAGE="bump_finch_0.5.3"
BRANCH_NAME="bump_finch_0.5.3"

# bumpversion config
IMAGE_VERSION_LOCATOR="FINCH_IMAGE"
NEW_IMAGE_TAG="0.5.3"
VERSION_FILE="birdhouse/default.env"

# hub config
GITHUB_USER=""
GITHUB_PASSWORD=""


git clone $REPO_URL
cd $PROJECT_NAME
git checkout -b $BRANCH_NAME

IMAGE_VERSION_LOCATOR=$IMAGE_VERSION_LOCATOR NEW_IMAGE_TAG=$NEW_IMAGE_TAG VERSION_FILE=$VERSION_FILE ./bump_version.sh

git add -A
git commit -m $COMMIT_MESSAGE
git push

hub pull-request -m $COMMIT_MESSAGE