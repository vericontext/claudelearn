---
name: check-progress
description: Check learning progress in study-guide.md. Auto-invoked when checking progress.
allowed-tools: Read, Grep, Glob
---

## Instructions

Do the following:

1. Parse the checklists (`- [ ]`, `- [x]`) in study-guide.md
2. Check the project file structure to verify actual completion
3. Output results in this format:

```
## Learning Progress

| Phase | Done | Total | Progress |
|-------|------|-------|----------|
| 1-1 Memory | ?/5 | 5 | ??% |
| 1-2 Permissions | ?/4 | 4 | ??% |
| ...

### Next Steps
- (highest priority incomplete item)
```
