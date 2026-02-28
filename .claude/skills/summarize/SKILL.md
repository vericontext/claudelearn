---
name: summarize
description: Compress a specific feature in note.md into a 1-minute summary. Use for quick review.
argument-hint: [feature-name - e.g. hooks, mcp, skills]
allowed-tools: Read, Grep
---

## Instructions

Find the section for `$ARGUMENTS` in note.md and create a **summary readable in under 1 minute**.

Format:
```
## $ARGUMENTS — 1-Minute Summary

**One-line definition**: ...
**Key 3 points**:
1. ...
2. ...
3. ...
**Most common pattern**: (one code example)
**Watch out for**: (one line)
```
