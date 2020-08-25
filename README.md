# DACCS Docker image updater


`[cronjob]` : Periodically trigger `fetch_tags.sh`
`fetch_tags.sh` : Check DockerHub image tags to trigger `pr_script.sh`
`pr_script.sh` : Clone repo, trigger `bump_version.sh` and create PR
`bump_version.sh` : Bump version of specific image in repo


