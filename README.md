# DACCS Docker image updater


Automatically updates `birdhouse-deploy` docker images as soon as new tags are pushed.


`[cronjob]` : Periodically trigger `main.sh`
<br>
`` : Iterates images defined in config to call `fetch_tags.sh`
<br>
`fetch_tags.sh` : Check DockerHub image tags to trigger `pr_script.sh`
<br>
`pr_script.sh` : Clone repo, trigger `bump_version.sh` and create PR
<br>
`bump_version.sh` : Bump version of specific image in repo

Note that env variables are passed implicitely all along the pipeline.


## Advantages

- Not dependent on Github API, since abstracted in `hub`
- Does not require a running docker instance


## Limitations

- Restricted to Github repositories
- Restricted to Dockerhub images
