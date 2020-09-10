

# Temporary file, to log todos


one pr for multiple image changes, need to handle this case later on, config to choose between the two modes
add retry mechanism, if task fails after triggering the pr_script
use GITHUB_TOKEN instead of GITHUB_USER and GITHUB_PASSWORD, for Hub
test with real repo push (to test credentials)
factor out to function integration test's log and assertion logic
    tag versions in variables, not hardcoded
move bump_file to image level, in config
configurable config.json path

add configuration for all bh deploy image files




---- 

jenkins (maybe not required)
issue with docker volume + persistence
print image name in slack
jenkins reboot (ansicolor plugin)