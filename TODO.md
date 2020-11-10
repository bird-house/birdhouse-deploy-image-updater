

# Temporary file, to log todos

## Priority

none


## thredds-docker config

seems to trigger false positive, so removed from configs

        {
            "id": "thredds-docker",
            "url": "https://hub.docker.com/r/unidata/thredds-docker",
            "dockerhub_repo_name": "unidata/thredds-docker",
            "bump_tag": "s@(.*unidata\\/thredds-docker:).*@\\1NEW_TAG_VALUE\"@",
            "bump_file": "birdhouse/default.env",
            "tag_filter": "^[0-9]+(\\.[0-9]+)$"
        }


for tests:
        {
            "name" : "thredds-docker",
			"bump_statement" : "bump_thredds-docker_to_4.6.15",
			"diff_expectation" : "export THREDDS_IMAGE=\"unidata/thredds-docker:4.6.15\""
		},



## weaver config

        {
            "id": "weaver",
            "url": "https://hub.docker.com/r/pavics/weaver",
            "dockerhub_repo_name": "pavics/weaver",
            "bump_tag": "WEAVER_IMAGE",
            "bump_file": "birdhouse/default.env",
            "tag_filter": "^[0-9]+(\\.[0-9]+)*$"
        },
        {
            "id": "weaver-manager",
            "url": "https://hub.docker.com/r/pavics/weaver",
            "dockerhub_repo_name": "pavics/weaver",
            "bump_tag": "WEAVER_MANAGER_IMAGE",
            "bump_file": "birdhouse/default.env",
            "tag_filter": "^[0-9]+(\\.[0-9]+)*-manager$"
        },
        {
            "id": "weaver-worker",
            "url": "https://hub.docker.com/r/pavics/weaver",
            "dockerhub_repo_name": "pavics/weaver",
            "bump_tag": "WEAVER_WORKER_IMAGE",
            "bump_file": "birdhouse/default.env",
            "tag_filter": "^[0-9]+(\\.[0-9]+)*-worker$"
        }