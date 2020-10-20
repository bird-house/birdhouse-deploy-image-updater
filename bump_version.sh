#!/bin/bash

###
# EXIT CODES
# 0 - success
# 1 - parameter error
###

# Sample environment variables
# BUMP_TAG="s/(.*pavics\/canarieapi:).*/\\1NEW_TAG_VALUE/"
# NEW_TAG_VALUE="0.3.6"
# BUMP_FILE="birdhouse/docker-compose.yml"

REQUIRED_ENV_VARS='
    BUMP_TAG
    NEW_TAG_VALUE
    BUMP_FILE
'

# args parsing
for env_var in $REQUIRED_ENV_VARS
do
    if [[ ! -v "${env_var}" ]]; then
        echo "[ERROR] [$0] Missing ${env_var} environment variable. Exiting."
        exit 1
    fi
done


PARSED_BUMP_TAG_EXPRESSION=${BUMP_TAG//NEW_TAG_VALUE/$NEW_TAG_VALUE}

# hack, to make sure regex expression is unsanitized
# conditional since calling bump_version.sh directly doesn't require this extra step, since not using JSON string escaping. like in config.test.json
if [[ "$PARSED_BUMP_TAG_EXPRESSION" == *"\\\\"* ]]; then
    PARSED_BUMP_TAG_EXPRESSION=$(printf "%b" $PARSED_BUMP_TAG_EXPRESSION)
fi

echo "[INFO] Using expression [$PARSED_BUMP_TAG_EXPRESSION]" 

sed -E -i'' $PARSED_BUMP_TAG_EXPRESSION $BUMP_FILE
