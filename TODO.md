

# Temporary file, to log todos

## Priority

modify the search & replace, since version tags won't always be structured the same way
    suggestion : add second pattern, for current version replacement
    handle multiple default.env file since each component now have their own default.env



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