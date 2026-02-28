# claudelearn

A personal reference repository for mastering Claude Code features — from basic configuration to advanced automation.

## What's in here

| File | Purpose |
|------|---------|
| `note.md` | Working notes — annotate, check off, edit freely |
| `note-reference.md` | Public reference — **do not modify** |
| `study-guide.md` | Step-by-step learning guide with checklists |

## Topics Covered

1. **Memory / CLAUDE.md** — project and global configuration
2. **Permissions** — allow/deny rules, permission modes
3. **Best Practices** — prompting, context management, workflows
4. **Skills** — custom slash commands (`/ship`, `/review`, etc.)
5. **Subagents** — specialized agents with isolated contexts
6. **Hooks** — deterministic automation on tool events
7. **MCP** — connecting external services (GitHub, Jira, Slack, DBs)
8. **Plugins** — packaging and distributing extensions
9. **Agent Teams** — multi-agent parallel execution
10. **Headless / Agent SDK** — non-interactive CLI automation
11. **CI/CD** — GitHub Actions integration
12. **Slack** — team collaboration via Claude App

## Built-in Skills

| Skill | Description |
|-------|-------------|
| `/ship` | Commit changes + create PR in one command |
| `/review [pr]` | Analyze PR diff and post review comments |
| `/summarize [feature]` | 1-minute summary of any note section |
| `/review-note [section]` | Review note quality against reference |
| `/check-progress` | Show learning progress across all phases |
| `/project-status` | Git status + file structure overview |

## Built-in Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `security-reviewer` | opus | OWASP Top 10 security analysis |
| `perf-reviewer` | sonnet | N+1 queries, memory leaks, render performance |
| `test-validator` | haiku | Test coverage verification |
| `note-reviewer` | sonnet | Note accuracy and completeness review |
| `note-updater` | sonnet | Update note sections from reference |
| `quick-search` | haiku | Fast keyword search across notes |
| `study-coach` | sonnet | Progress analysis and study planning |

## Hooks Configured

- **PostToolUse** (`Edit|Write`) — echo timestamp on every file edit
- **PreToolUse** (`Edit|Write`) — block edits to `note-reference.md`
- **SessionStart** (`compact`) — inject project reminders after context compression
- **Notification** — macOS notification when Claude needs attention

## MCP

GitHub MCP server configured in `.mcp.json` (project scope).

```
@github:issue://123 implement this issue
```

## Getting Started

```bash
git clone https://github.com/vericontext/claudelearn
cd claudelearn
claude  # open Claude Code in this directory
```

Open `study-guide.md` and work through the phases in order. Each phase builds on the previous one.

## CI/CD

Two GitHub Actions workflows are included:

- `claude.yml` — responds to `@claude` mentions in issues and PR comments
- `claude-review.yml` — automated PR code review via Claude
