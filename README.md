# DACCS Docker image updater


STATUS : Experimental

Automatically updates `birdhouse-deploy` docker images as soon as new tags are pushed.


# Usage

## Docker

To run the image updater using Docker:

```
chmod +x ./Taskfile

# remove `EXIT_BEFORE_PR=1` if you want to actually create the PR
HISTORIC_TAG_DATA_PATH=/absolute-and-writable-path EXIT_BEFORE_PR=1 GITHUB_USER=XXXX GITHUB_PASSWORD=YYYY ./Taskfile build-run

# Clean historic tag data
HISTORIC_TAG_DATA_PATH=/absolute-and-writable-path ./Taskfile clean-data
```

To run the integration test via Docker:

```
# Run integration test. Won't push the PR, since `EXIT_BEFORE_PR=1` is seeded
HISTORIC_TAG_DATA_PATH=/absolute-and-writable-path ./Taskfile build-test
```



## Command line

### Requirements

```
- hub (via brew)
- jq

.. and for tests ..

- python3
```

To run the image updater using CLI:

```
# remove `EXIT_BEFORE_PR=1` if you want to actually create the PR
EXIT_BEFORE_PR=1 GITHUB_USER=XXXX GITHUB_PASSWORD=YYYY ./main.sh
```

To run the integration test via CLI:

```
cd tests/integration && ./integration_test_runner.sh
```


# Tests

E2E integration test with DockerHub API mock available in `tests/integration`.
It mimicks an image tag push on DockerHub, then runs the updater script and checks that the proper commit is made.
Makes that assumption that the `hub` CLI tool will open the PR properly after then.


# Flow


`[cronjob]` : Periodically trigger `main.sh`
<br>
`main.sh` : Iterates images defined in config to call `fetch_tags.sh`
<br>
`fetch_tags.sh` : Check DockerHub image tags to trigger `pr_script.sh`
<br>
`pr_script.sh` : Clone repo, trigger `bump_version.sh` and create PR
<br>
`bump_version.sh` : Bump version of specific image in repo

Tags containing "latest" are not taken into account, since usage should be avoided in any ways in `birdhouse-deploy` repo.


# Advantages

- Not dependent on Github API, since abstracted in `hub`
- Does not require a running docker instance


# Limitations

- Restricted to Github repositories
- Restricted to Dockerhub images



