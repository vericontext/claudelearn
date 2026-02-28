---
name: review
description: Code review for a PR. Pass the PR number as /review 123.
argument-hint: "[pr-number]"
---
## PR #$ARGUMENTS Review Request

Changed files:
!`gh pr diff $ARGUMENTS --name-only`

Full diff:
!`gh pr diff $ARGUMENTS`

Existing comments:
!`gh pr view $ARGUMENTS --comments`

Based on the above, analyze bugs, security issues, performance problems, and improvements, then post a review comment on the PR.
