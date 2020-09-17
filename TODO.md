

# Temporary file, to log todos

## Priority

modify the search & replace, since version tags won't always be structured the same way
    suggestion : add second pattern, for current version replacement
    handle multiple default.env file since each component now have their own default.env
add configuration for all bh deploy image files
    add fuzzy test, to test images tag push for ALL components
configuration management : less env var, maybe one config per script
    add `env.default` and `env.custom`, for documentation purposes
    add `GITHUB_TOKEN` to env file



## Backlog

one pr for multiple image changes, need to handle this case later on, config to choose between the two modes
add retry mechanism, if task fails after triggering the pr_script
factor out to function integration test's log and assertion logic
    tag versions in variables, not hardcoded
configurable `config.json` path
handle PR errors (eg: currently states that PR is created and send slack notif even if PR issue might have occured)
use functions instead of splitting logic in multiple files (?)




### Suggestion from Long (translates to TODO)

If the NEW_IMAGE_TAG_DECLARATION in bump_version.sh is also moved to config.json as a template string, I think we can seriously achieve generic find-replace that can work for any file format, not just default.env in birdhouse-deploy. So the config.json committed becomes a sample config pre-configured for birdhouse-deploy repo.