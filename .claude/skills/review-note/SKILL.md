---
name: review-note
description: Review a specific section of note.md and suggest improvements. Use when checking note quality.
argument-hint: [section-number or feature-name]
allowed-tools: Read, Grep, Glob
---

## Instructions

Find the section in note.md matching `$ARGUMENTS` and review it.

Review criteria:
1. **Accuracy**: Compare against note-reference.md for missing info or errors
2. **Practicality**: Is it usable as a quick reference during real work?
3. **Conciseness**: Any unnecessary repetition or verbose explanations?

Output format:
- Score: /10
- Strengths: (briefly)
- Suggestions: (specifically)
