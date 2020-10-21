#!/bin/bash

# NOTE : Would need complete refactoring, lot of hardcoded values and logic.

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;36m'
NC='\033[0m'

DATA_DIR="data"
SUCCESS_COUNT=0
FAILURE_COUNT=0

ENV_FILENAME="../../"$ENV_FILE

if [ ! -f $ENV_FILENAME ]; then
    echo "[INFO] Env file not existing. Exiting."
    exit 1
fi

source $ENV_FILENAME
echo "[INFO] USING ENVIRONMENT FILE ${ENV_FILENAME}"

if [[ -z "${DOCKERHUB_HOST}" ]]; then
    echo "[WARNING] DOCKERHUB_HOST not defined. Exiting."
    exit 1
fi

DOCKERHUB_HOST_TEST=$DOCKERHUB_HOST

# free port for dummy API
lsof -ti tcp:5555 | xargs kill &> /dev/null

# start the dummy API
printf "%s\n" "" "    [TEST] Starting dummy APIs" ""
python mock_dockerhub_api.py &> /dev/null &
echo "done"

cd ../..


####

function push_initial_tags_all_images {
    # push ALL images
    printf "%s\n" "" "    [INFO] Pushing all initial tags to DockerHub" ""
    printf "${BLUE}"
    curl -s -XPOST $DOCKERHUB_HOST_TEST/birdhouse/finch/version-0.5.4
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/canarieapi/0.3.5
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/pavics-frontend/1.0.5
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/pavics-project-api/0.9.0
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/pyramid-phoenix/pavics-0.2.3
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/pavics-datacatalog/0.6.11
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/geoserver/2.9.3
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/malleefowl/pavics-0.3.5
    curl -s -XPOST $DOCKERHUB_HOST_TEST/birdhouse/flyingpigeon/1.6
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/raven/0.10.0
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/hummingbird/0.5_dev
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/solr/5.2.1
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/ncwms2/2.0.4
    curl -s -XPOST $DOCKERHUB_HOST_TEST/unidata/thredds-docker/4.6.14
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/postgis/2.2
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/magpie/1.7.3
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/twitcher/magpie-1.7.3
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/jupyterhub/1.0.0-20200130

    # extra components
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/weaver/1.13.3-worker
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/weaver/1.13.3-manager
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/weaver/1.13.3
    printf "${NC}"
    echo
}


function update_all_images {
    # update ALL images
    printf "%s\n" "" "    [INFO] Pushing all tags to DockerHub" ""
    printf "${BLUE}"
    curl -s -XPOST $DOCKERHUB_HOST_TEST/birdhouse/finch/version-0.5.5
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/canarieapi/0.3.6
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/pavics-frontend/1.0.6
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/pavics-project-api/0.9.1
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/pyramid-phoenix/pavics-0.2.4
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/pavics-datacatalog/0.6.12
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/geoserver/2.9.4
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/malleefowl/pavics-0.3.6
    curl -s -XPOST $DOCKERHUB_HOST_TEST/birdhouse/flyingpigeon/1.7
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/raven/0.10.1
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/hummingbird/0.6_dev
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/solr/5.2.2
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/ncwms2/2.0.5
    curl -s -XPOST $DOCKERHUB_HOST_TEST/unidata/thredds-docker/4.6.15
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/postgis/2.3
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/magpie/1.7.4
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/twitcher/magpie-1.7.4
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/jupyterhub/1.0.0-20200131

    # extra components
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/weaver/1.13.4-worker
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/weaver/1.13.4-manager
    curl -s -XPOST $DOCKERHUB_HOST_TEST/pavics/weaver/1.13.4
    printf "${NC}"
    echo
}

####

push_initial_tags_all_images

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - no PR to create" ""
rm -f last-diff-result.log
ONLY_UPDATE_TAGS_HISTORY=true ./main.sh

update_all_images

IMAGE_COUNT=$(cat ./tests/integration/test.json | jq '.images | length')

for ((n=0; n<$IMAGE_COUNT; n++))
do
    CURRENT_IMAGE=$(cat ./tests/integration/test.json | jq '.images['$n']')
    BUMP_STATEMENT=$(echo $CURRENT_IMAGE | jq '.bump_statement' | tr -d '\"')
    DIFF_EXPECTATION=$(echo $CURRENT_IMAGE | jq '.diff_expectation')
    DIFF_EXPECTATION=${DIFF_EXPECTATION:1:-1}    # remove first and last string quotes

    # run updater CLI
    printf "%s\n" "" "    [TEST] Running updater - need to create a PR" ""
    rm -f last-diff-result.log
    ./main.sh


    ### Asserts that diff contains the right thing
    printf "%s\n" "" "    [TEST] ASSERT" ""
    if grep -q "$DIFF_EXPECTATION" "last-diff-result.log"; then
        printf "${GREEN}[INFO] [$BUMP_STATEMENT] The commit content looks good"
        echo
        echo
        cat last-diff-result.log
        printf "${NC}"
        ((SUCCESS_COUNT++))
    else
        printf "${RED}[ERROR] [$BUMP_STATEMENT] wrong commit content."
        echo
        echo
        cat last-diff-result.log
        printf "${NC}"
        ((FAILURE_COUNT++))
    fi
done

push_initial_tags_all_images

# tag snapshot
ONLY_UPDATE_TAGS_HISTORY=true ./main.sh

update_all_images

PUSHED_TAGS_COUNT=18

# dry run
DRY_RUN=1 ./main.sh | tee tmp.log

UPDATED_TAGS=$(cat tmp.log | grep -c "Found new tag")
rm tmp.log


### Asserts that correct number of images have been updated
printf "%s\n" "" "    [TEST] ASSERT" ""
if [[ $PUSHED_TAGS_COUNT -eq $UPDATED_TAGS ]]; then
    printf "${GREEN}[INFO] All image tags push have triggered the image updater."
    echo
    echo
    printf "${NC}"
    ((SUCCESS_COUNT++))
else
    printf "${RED}[ERROR] Wrong number of image tag resulting in PR. Expecting [$PUSHED_TAGS_COUNT], got [$UPDATED_TAGS]."
    echo
    echo
    printf "${NC}"
    ((FAILURE_COUNT++))
fi


# kill the dummy API
printf "%s\n" "" "    [TEST] Stopping dummy APIs" ""
lsof -ti tcp:5555 | xargs kill &> /dev/null
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
    exit 100        # for testing purposes, we emulate a successful image tag update exit status code
else 
    printf "${RED}[ERROR] Some tests failed."
    echo
    echo
    echo "Success : $SUCCESS_COUNT"
    echo "Failure : $FAILURE_COUNT"
    printf "${NC}"
    exit 1
fi
