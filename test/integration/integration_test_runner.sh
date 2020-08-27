#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# free port for dummy API
lsof -ti tcp:5000 | xargs kill &> /dev/null

# start the dummy API
printf "%s\n" "" "    [TEST] Starting dummy APIs" ""
python3 mock_dockerhub_api.py &> /dev/null  &
echo "done"

# cd to main dir and clean historic tag data
cd ../..
rm -rf data/

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - no PR to create" ""
rm -f last-diff-result.log
source test/integration/env.test && ONLY_UPDATE_TAGS_HISTORY=true ./main.sh

# update an image
printf "%s\n" "" "    [TEST] Pushing weaver tag to DockerHub" ""
curl -XPOST localhost:5000/pavics/weaver/1.13.2-worker

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - need to create a PR for [bump_weaver-worker_to_1.13.2-worker]" ""
rm -f last-diff-result.log
source test/integration/env.test && ./main.sh


### Asserts that diff contains the right thing
printf "%s\n" "" "    [TEST] ASSERT" ""
if grep -q 'export WEAVER_WORKER_IMAGE="pavics/weaver:1.13.2-worker"' "last-diff-result.log"; then
    printf "${GREEN}[INFO] [bump_weaver-worker_to_1.13.2-worker] The commit content looks good"
    echo
    cat last-diff-result.log
    printf "${NC}"
else
    printf "${RED}[ERROR] [bump_weaver-worker_to_1.13.2-worker] wrong commit content. Exiting."
    echo
    cat last-diff-result.log
    printf "${NC}"
    exit 1
fi


# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - no PR to create" ""
rm -f last-diff-result.log
source test/integration/env.test && ./main.sh

# update an image
printf "%s\n" "" "    [TEST] Pushing weaver and finch tags to DockerHub" ""
curl -XPOST localhost:5000/pavics/weaver/1.13.3-worker
curl -XPOST localhost:5000/birdhouse/finch/version-0.5.4


# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - need to create a PR for [bump_finch_to_version-0.5.4]" ""
rm -f last-diff-result.log
source test/integration/env.test && ./main.sh


### Asserts that diff contains the right thing
printf "%s\n" "" "    [TEST] ASSERT" ""
if grep -q 'export FINCH_IMAGE="birdhouse/finch:version-0.5.4"' "last-diff-result.log"; then
    printf "${GREEN}[INFO] [bump_finch_to_version-0.5.4] The commit content looks good"
    echo
    cat last-diff-result.log
    printf "${NC}"
else
    printf "${RED}[ERROR] [bump_finch_to_version-0.5.4] wrong commit content. Exiting."
    echo
    cat last-diff-result.log
    printf "${NC}"
    exit 1
fi


# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - need to create a PR for [bump_weaver-worker_to_1.13.3-worker]" ""
rm -f last-diff-result.log
source test/integration/env.test && ./main.sh


### Asserts that diff contains the right thing
printf "%s\n" "" "    [TEST] ASSERT" ""
if grep -q 'export WEAVER_WORKER_IMAGE="pavics/weaver:1.13.3-worker"' "last-diff-result.log"; then
    printf "${GREEN}[INFO] [bump_weaver-worker_to_1.13.3-worker] The commit content looks good"
    echo
    cat last-diff-result.log
    printf "${NC}"
else
    printf "${RED}[ERROR] [bump_weaver-worker_to_1.13.3-worker] wrong commit content. Exiting."
    echo
    cat last-diff-result.log
    printf "${NC}"
    exit 1
fi


# kill the dummy API
printf "%s\n" "" "    [TEST] Stopping dummy APIs" ""
lsof -ti tcp:5000 | xargs kill
echo "done"



