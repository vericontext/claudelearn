---
name: ship
description: Commit current changes and create a PR. Use when finishing a task.
---
## Current Changes
!`git diff --staged`
!`git diff`

Analyze the changes above and:
1. Write a commit message summarizing the changes (English, under 50 chars)
2. Run git add -A && git commit
3. Write a PR title and body in English
4. Run gh pr create
