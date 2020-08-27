# DACCS Docker image updater


STATUS : Experimental

Automatically updates `birdhouse-deploy` docker images as soon as new tags are pushed.

## Requirements

- hub (via brew)
- jq

.. and for tests ..

- python3


## Setup

- Define 'GITHUB_USER'
- Define 'GITHUB_PASSWORD'


## Flow


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

## Command line

```
# first time use, to initiate historical data in `data/`
ONLY_UPDATE_TAGS_HISTORY=true ./main.sh

# then
./main.sh
```

## Docker

```
chmod +x ./Taskfile

# Run
HISTORIC_TAG_DATA_PATH=/historic-tag-data GITHUB_USER=XXXX GITHUB_PASSWORD=YYYY ./Taskfile build-run

# Run integration test
./Taskfile build-test

# Clean historic tag data
./Taskfile clean-data
```


# Tests

E2E integration test with DockerHub API mock available in `tests/integration`.
It mimicks an image tag push on DockerHub, then runs the updater script and checks that the proper commit is made.
Assumption that the `hub` CLI tool will open the PR properly after then.

To run the integration test:

```
cd tests/integration && ./integration_test_runner.sh
```