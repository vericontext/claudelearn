# Slack Integration Setup Checklist

## Prerequisites
- [ ] Claude Pro/Max/Teams/Enterprise plan (includes Claude Code access)
- [ ] [claude.ai/code](https://claude.ai/code) access enabled
- [ ] GitHub account connected to Claude Code web

## Setup steps

### 1. Install Slack app
- [ ] Workspace admin installs from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)

### 2. Connect Claude account
- [ ] Slack → Apps → Claude → App Home → click "Connect"

### 3. Set up Claude Code web
- [ ] Go to [claude.ai/code](https://claude.ai/code)
- [ ] Connect GitHub account
- [ ] Authorize repos (including claudelearn)

### 4. Select routing mode
- [ ] Choose in App Home:
  - **Code only**: all @Claude → Claude Code session
  - **Code + Chat**: coding to Code, general questions to Chat (auto-routed)

### 5. Add to channel
- [ ] Run `/invite @Claude` in desired channel

## Test
- [ ] `@Claude analyze study-guide.md in this repo and tell me my progress`
- [ ] Verify View Session / Create PR buttons appear
