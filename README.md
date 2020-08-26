# DACCS Docker image updater


STATUS : Experimental

## Requirements

- hub (via brew)
- jq

.. and for tests ..

- python3


Automatically updates `birdhouse-deploy` docker images as soon as new tags are pushed.


`[cronjob]` : Periodically trigger `main.sh`
<br>
`main.sh` : Iterates images defined in config to call `fetch_tags.sh`
<br>
`fetch_tags.sh` : Check DockerHub image tags to trigger `pr_script.sh`
<br>
`pr_script.sh` : Clone repo, trigger `bump_version.sh` and create PR
<br>
`bump_version.sh` : Bump version of specific image in repo

Tags containing "latest" are taken into account, since usage should be avoided in any ways in `birdhouse-deploy` repo.

Hypothesis taken at the moment is that only one image change is done at given time. This limitation needs to be removed, since if two images are updated, the second one will be discarded.

## Advantages

- Not dependent on Github API, since abstracted in `hub`
- Does not require a running docker instance


## Limitations

- Restricted to Github repositories
- Restricted to Dockerhub images



# Usage

```
# first time use, to initiate historical data in `data/`
ONLY_UPDATE_TAGS_HISTORY=true ./main.sh

# then
./main.sh
```


# Tests

E2E integration test with DockerHub and GitHub API mocks are available in `test/integration`.
It mimicks an image tag push on DockerHub, then runs the updater script and checks if a new PR has been opened.