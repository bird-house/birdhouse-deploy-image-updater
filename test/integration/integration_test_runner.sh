# free port for dummy API
lsof -ti tcp:5000 | xargs kill &> /dev/null

# start the dummy API
printf "%s\n" "" "    [TEST] Starting dummy APIs" ""
python3 mock_dockerhub_api.py &> /dev/null  &
echo "done"

cd ../..
rm last-diff-result.log

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - no PR to create" ""
source test/integration/env.test && ONLY_UPDATE_TAGS_HISTORY=true ./main.sh

# update an image
printf "%s\n" "" "    [TEST] Pushing finch tag to DockerHub" ""
curl -XPOST localhost:5000/pavics/weaver/1.13.2-worker

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - need to create a PR" ""
source test/integration/env.test && ./main.sh

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater - no PR to create" ""
source test/integration/env.test && ./main.sh

# kill the dummy API
printf "%s\n" "" "    [TEST] Stopping dummy APIs" ""
lsof -ti tcp:5000 | xargs kill
echo "done"



### Test assertion
printf "%s\n" "" "    [TEST] RESULTS" ""
if grep -q 'export FINCH_IMAGE="pavics/weaver:1.13.2-worker"' "last-diff-result.log"; then
    echo "The commit content looks good"
    echo
    cat last-diff-result.log
    exit 0
else
    echo "ERROR - wrong commit content"
    exit 1
fi