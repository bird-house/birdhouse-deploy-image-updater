# DACCS Docker image updater


Automatically updates `birdhouse-deploy` docker images as soon as new tags are pushed.


`[cronjob]` : Periodically trigger `fetch_tags.sh`
<br>
`fetch_tags.sh` : Check DockerHub image tags to trigger `pr_script.sh`
<br>
`pr_script.sh` : Clone repo, trigger `bump_version.sh` and create PR
<br>
`bump_version.sh` : Bump version of specific image in repo


