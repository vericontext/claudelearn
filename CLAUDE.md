# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# claudelearn

This is a personal learning repository for Claude Code features.

## File Roles

- `note-reference.md` — public reference. **Do not modify**
- `note.md` — personal working notes. Freely editable
- `study-guide.md` — step-by-step learning guide with checklists

## Available Skills

| Skill | Description |
|-------|-------------|
| `/summarize` | 1-minute summary of a note.md section |
| `/review-note` | Review and suggest improvements for a note.md section |
| `/check-progress` | Check learning progress in study-guide.md |
| `/project-status` | Git status + file structure summary |
| `/ship` | Commit current changes and create a PR |
| `/review [pr-number]` | Analyze PR diff and post review comments |

## Active Agents

- `note-reviewer` — validate note.md quality
- `note-updater` — update note.md sections
- `quick-search` — search notes for keywords
- `study-coach` — learning progress coaching
- `security-reviewer` — OWASP Top 10 security analysis
- `perf-reviewer` — N+1 query / memory leak detection
- `test-validator` — test coverage verification

## Rules

- Commit messages in English
- `note-reference.md` edits are automatically blocked by a PreToolUse hook
