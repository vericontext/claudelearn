#!/bin/bash
# =============================================
# Phase 4-3: Agent Teams practice script
# =============================================
# Experimental feature — enable before use

# -------------------------------------------
# Method 1: Enable via env var (one-time)
# -------------------------------------------
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude

# -------------------------------------------
# Method 2: Permanent setting in settings.json
# -------------------------------------------
# Add to ~/.claude/settings.json:
# {
#   "env": {
#     "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
#   }
# }

# -------------------------------------------
# Usage after enabling
# -------------------------------------------
# Inside a session:
#
# > Review the Hooks section and MCP section of note.md simultaneously.
# >   Teammate 1: Verify Hooks section accuracy
# >   Teammate 2: Verify MCP section accuracy
# >   Synthesize both results into a report
#
# Claude forms a team and teammates work in parallel.

# -------------------------------------------
# Display modes
# -------------------------------------------
# in-process: switch teammates with Shift+Down
claude --teammate-mode in-process

# split panes: requires tmux or iTerm2
# claude --teammate-mode split-panes

# -------------------------------------------
# Limitations (experimental)
# -------------------------------------------
# - Only one team per session
# - No nested teams (teammates can't create teams)
# - In-process teammates not restored on session resume
# - Higher token cost than Subagents
