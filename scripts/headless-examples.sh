#!/bin/bash
# =============================================
# Phase 3-2: Headless / Agent SDK practice script
# =============================================
# Run examples one at a time (do not run all at once)
# Usage: copy an example below and paste into terminal

# -------------------------------------------
# Exercise 1: Basic headless + JSON output
# -------------------------------------------

# Text output (default)
claude -p "Describe the file structure of this project" --output-format text

# JSON output (with metadata)
claude -p "Describe the file structure of this project" --output-format json

# Extract result field from JSON
claude -p "Describe the file structure of this project" --output-format json | jq -r '.result'

# -------------------------------------------
# Exercise 2: --allowedTools auto-approve
# -------------------------------------------

# Allow read-only tools (run without approval prompts)
claude -p "Find the MCP section in note.md and summarize it" \
  --allowedTools "Read,Grep,Glob"

# Auto-approve git commands
claude -p "Analyze the last 5 commits and describe the pattern" \
  --allowedTools "Bash(git log *),Bash(git diff *),Read"

# -------------------------------------------
# Exercise 3: Unix pipe patterns
# -------------------------------------------

# Ask Claude to analyze git log
git log --oneline -5 | claude -p "Analyze this commit history and describe the project progress"

# Pipe file content
cat study-guide.md | claude -p "List the incomplete items in this study guide"

# -------------------------------------------
# Exercise 4: Continue a session
# -------------------------------------------

# First request
claude -p "Analyze the Skills section in note.md" --output-format text

# Continue previous session (--continue)
claude -p "Summarize the 3 most important points from that analysis" --continue

# Resume specific session (save session_id first)
# session_id=$(claude -p "Start project analysis" --output-format json | jq -r '.session_id')
# claude -p "Continue the analysis" --resume "$session_id"

# -------------------------------------------
# Exercise 5: Practical script — note section summarizer
# -------------------------------------------

# Add the function below to .zshrc or .bashrc
# Usage: note_summary hooks
note_summary() {
  local topic="${1:?Usage: note_summary <topic>}"
  grep -A 100 "## .*${topic}" note.md | head -50 | \
    claude -p "Summarize this in 3 lines." --output-format text
}
