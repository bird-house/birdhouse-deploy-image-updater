
DOCKER_HUB_REPO="birdhouse/finch"

DATA_DIR="data"


# get image tags from dockerhub
mkdir -p data
NAME=${DOCKER_HUB_REPO/\//_}
NEW_FILENAME=$NAME.new
NEW_FILEPATH=$DATA_DIR/$NEW_FILENAME
wget -q https://registry.hub.docker.com/v1/repositories/$DOCKER_HUB_REPO/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}' > $NEW_FILEPATH


# make sure data is persisted to file
if [ ! -f "$NEW_FILEPATH" ]; then
    echo "[WARNING] Error when pulling DockerHub data. Exiting."
    exit 50
fi


# diff
OLD_FILENAME=$NAME.old
OLD_FILEPATH=$DATA_DIR/$OLD_FILENAME

if [ -f "$OLD_FILEPATH" ] && [ -f "$NEW_FILEPATH" ]; then
    diff $OLD_FILEPATH $NEW_FILEPATH

    # rotate historical files
    echo $OLD_FILEPATH
    rm $OLD_FILEPATH
    mv $NEW_FILEPATH $OLD_FILEPATH
else
    echo "[INFO] No old file found to compare with. Skipping diff."
fi


# launch pr_script with params