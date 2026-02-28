---
name: project-status
description: Summarize the current git status and file structure of the project
---

## Project Status Report

Summarize the project status based on the dynamic context below.

### Git Status
!`git status --short`

### Recent Commits
!`git log --oneline -5`

### File Structure
!`find . -not -path './.git/*' -type f | head -20`

Based on the above:
1. Current branch and commit status
2. Summary of changed/added files
3. Suggested next steps
