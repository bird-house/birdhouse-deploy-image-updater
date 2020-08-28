#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;36m'
NC='\033[0m'

DATA_DIR="data"
SUCCESS_COUNT=0
FAILURE_COUNT=0

# free port for dummy API
lsof -ti tcp:5000 | xargs kill &> /dev/null

# start the dummy API
printf "%s\n" "" "    [TEST] Starting dummy APIs" ""
python mock_dockerhub_api.py &> /dev/null &
echo "done"

cd ../..

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - no PR to create" ""
rm -f last-diff-result.log
source tests/integration/env.test && ONLY_UPDATE_TAGS_HISTORY=true ./main.sh

# update an image
printf "%s\n" "" "    [INFO] Pushing weaver tag to DockerHub" ""
printf "${BLUE}"
curl -s -XPOST localhost:5000/pavics/weaver/1.13.2-worker
printf "${NC}"

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - need to create a PR for [bump_weaver-worker_to_1.13.2-worker]" ""
rm -f last-diff-result.log
source tests/integration/env.test && ./main.sh


### Asserts that diff contains the right thing
printf "%s\n" "" "    [TEST] ASSERT" ""
if grep -q 'export WEAVER_WORKER_IMAGE="pavics/weaver:1.13.2-worker"' "last-diff-result.log"; then
    printf "${GREEN}[INFO] [bump_weaver-worker_to_1.13.2-worker] The commit content looks good"
    echo
    echo
    cat last-diff-result.log
    printf "${NC}"
    ((SUCCESS_COUNT++))
else
    printf "${RED}[ERROR] [bump_weaver-worker_to_1.13.2-worker] wrong commit content."
    echo
    echo
    cat last-diff-result.log
    printf "${NC}"
    ((FAILURE_COUNT++))
fi


# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - no PR to create" ""
rm -f last-diff-result.log
source tests/integration/env.test && ./main.sh

# update an image
printf "%s\n" "" "    [INFO] Pushing weaver and finch tags to DockerHub" ""
printf "${BLUE}"
curl -s -XPOST localhost:5000/pavics/weaver/1.13.3-worker
curl -s -XPOST localhost:5000/birdhouse/finch/version-0.5.4
printf "${NC}"

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - need to create a PR for [bump_finch_to_version-0.5.4]" ""
rm -f last-diff-result.log
source tests/integration/env.test && ./main.sh


### Asserts that diff contains the right thing
printf "%s\n" "" "    [TEST] ASSERT" ""
if grep -q 'export FINCH_IMAGE="birdhouse/finch:version-0.5.4"' "last-diff-result.log"; then
    printf "${GREEN}[INFO] [bump_finch_to_version-0.5.4] The commit content looks good"
    echo
    echo
    cat last-diff-result.log
    printf "${NC}"
    ((SUCCESS_COUNT++))
else
    printf "${RED}[ERROR] [bump_finch_to_version-0.5.4] wrong commit content."
    echo
    echo
    cat last-diff-result.log
    printf "${NC}"
    ((FAILURE_COUNT++))
fi


# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - need to create a PR for [bump_weaver-worker_to_1.13.3-worker]" ""
rm -f last-diff-result.log
source tests/integration/env.test && ./main.sh


### Asserts that diff contains the right thing
printf "%s\n" "" "    [TEST] ASSERT" ""
if grep -q 'export WEAVER_WORKER_IMAGE="pavics/weaver:1.13.3-worker"' "last-diff-result.log"; then
    printf "${GREEN}[INFO] [bump_weaver-worker_to_1.13.3-worker] The commit content looks good"
    echo
    echo
    cat last-diff-result.log
    printf "${NC}"
    ((SUCCESS_COUNT++))
else
    printf "${RED}[ERROR] [bump_weaver-worker_to_1.13.3-worker] wrong commit content."
    echo
    echo
    cat last-diff-result.log
    printf "${NC}"
    ((FAILURE_COUNT++))
fi


# update ALL images
printf "%s\n" "" "    [INFO] Pushing all tags to DockerHub" ""
printf "${BLUE}"
curl -s -XPOST localhost:5000/pavics/weaver/1.13.4-worker
curl -s -XPOST localhost:5000/pavics/weaver/1.13.4-manager
curl -s -XPOST localhost:5000/pavics/weaver/1.13.4
curl -s -XPOST localhost:5000/birdhouse/finch/version-0.5.5
printf "${NC}"
PUSHED_TAGS_COUNT=4
echo

# count number of updated image tags
UPDATED_IMAGE_COUNTER=-1
exitCode=100

while [[ $exitCode -eq 100 ]]
do
    # run updater CLI
    rm -f last-diff-result.log
    source tests/integration/env.test && ./main.sh

    exitCode=$?
    UPDATED_IMAGE_COUNTER=$((UPDATED_IMAGE_COUNTER+1))
    cat $DATA_DIR/last-update-result.log >> $DATA_DIR/updated-images-list.log
done


### Asserts that correct number of images have been updated
printf "%s\n" "" "    [TEST] ASSERT" ""
if [[ $UPDATED_IMAGE_COUNTER -eq $PUSHED_TAGS_COUNT ]]; then
    printf "${GREEN}[INFO] All image tags push created a PR have triggered the image updater."
    echo
    echo
    cat $DATA_DIR/updated-images-list.log
    printf "${NC}"
    ((SUCCESS_COUNT++))
else
    printf "${RED}[ERROR] Wrong number of image tag resulting in PR. Expecting [$PUSHED_TAGS_COUNT], got [$UPDATED_IMAGE_COUNTER]."
    echo
    echo
    cat $DATA_DIR/updated-images-list.log
    printf "${NC}"
    ((FAILURE_COUNT++))
fi


# update an image
printf "%s\n" "" "    [INFO] Pushing weaver tag to DockerHub" ""
printf "${BLUE}"
curl -s -XPOST localhost:5000/pavics/weaver/1.13.5-worker
printf "${NC}"

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - need to create a PR for [bump_weaver-worker_to_1.13.4-worker]" ""
rm -f last-diff-result.log
source tests/integration/env.test && ./main.sh


### Assert
printf "%s\n" "" "    [TEST] ASSERT" ""
if grep -q '1.13.5-worker' "$DATA_DIR/last-update-result.log"; then
    printf "${GREEN}[INFO] [bump_weaver-worker_to_1.13.5-worker] 'last-update-result.log' looks good"
    echo
    echo
    cat $DATA_DIR/last-update-result.log
    printf "${NC}"
    ((SUCCESS_COUNT++))
else
    printf "${RED}[ERROR] [bump_weaver-worker_to_1.13.5-worker] wrong 'last-update-result.log'."
    echo
    echo
    cat $DATA_DIR/last-update-result.log
    printf "${NC}"
    ((FAILURE_COUNT++))
fi


# kill the dummy API
printf "%s\n" "" "    [TEST] Stopping dummy APIs" ""
lsof -ti tcp:5000 | xargs kill &> /dev/null
echo "done"
echo

# clean workspace
rm -f $DATA_DIR/updated-images-list.log

# test summary
if [[ $FAILURE_COUNT -eq 0 ]]; then
    printf "${GREEN}[INFO] All tests passed."
    echo
    echo
    echo "Success : $SUCCESS_COUNT"
    echo "Failure : $FAILURE_COUNT"
    printf "${NC}"
    exit 0
else 
    printf "${RED}[ERROR] Some tests failed."
    echo
    echo
    echo "Success : $SUCCESS_COUNT"
    echo "Failure : $FAILURE_COUNT"
    printf "${NC}"
    exit 1
fi