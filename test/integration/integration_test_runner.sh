
# start the dummy APIs
python3 mock_dockerhub_api.py &

cd ../..

# run updater CLI
source test/integration/env.test && ./main.sh


# update an image
curl -XPOST localhost:5000/birdhouse/finch/version-0.5.4

# run updater CLI
source test/integration/env.test && ./main.sh

# run updater CLI
source test/integration/env.test && ./main.sh




# kill the dummy APIs
lsof -ti tcp:5000 | xargs kill