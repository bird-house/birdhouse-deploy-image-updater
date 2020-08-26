
# free port for dummy APIs
lsof -ti tcp:5000 | xargs kill &> /dev/null

# start the dummy APIs
printf "%s\n" "" "    [TEST] Starting dummy APIs" ""
python3 mock_dockerhub_api.py &> /dev/null  &
echo "done"

cd ../..

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater" ""
source test/integration/env.test && ONLY_UPDATE_TAGS_HISTORY=true ./main.sh

# update an image
printf "%s\n" "" "    [TEST] Pushing finch tag" ""
curl -XPOST localhost:5000/birdhouse/finch/version-0.5.4

# run updater CLI
printf "%s\n" "" "    [TEST] Running updater" ""
source test/integration/env.test && ./main.sh

# # run updater CLI
printf "%s\n" "" "    [TEST] Running updater" ""
source test/integration/env.test && ./main.sh

# kill the dummy APIs
printf "%s\n" "" "    [TEST] Stopping dummy APIs" ""
lsof -ti tcp:5000 | xargs kill
echo "done"
