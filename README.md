# Github to Things 3

The first workflow loads all PR review requests from Github from a specific organization specified in an ENV variable, as todos into a specific project in Things 3.

When the review request is fulfilled, it also automatically marks that todo as done.

# Setup

- Create a .env file and fill in the required parameters (see sample file)
- Run it manually to check that it works: `ruby review_requests_to_things`

# Launchctl

To automatically make it run, edit the `workflow.plist` file with the correct paths for your installation, then link it into the `LaunchAgents` folder, with a custom name, for example:

```
ln workflow.plist ~/Library/LaunchAgents/com.crowdway.workflow.plist
```

And then load it:
```
launchctl load ~/Library/LaunchAgents/com.crowdway.workflow.plist
```

This will cause the ruby script to run every two minutes, or according to the interval specified in `workflow.plist`
