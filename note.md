# Claude Code Feature Deep Dive Notes

> Official docs: https://code.claude.com/docs/en/overview
> Full table of contents: https://code.claude.com/docs/llms.txt

---

## Learning Status

| Feature | Status | Part | Doc Link |
|---------|--------|------|----------|
| Memory / CLAUDE.md | ✅ Done | 1 | [memory](https://code.claude.com/docs/en/memory) |
| Permissions | ✅ Done | 1 | [permissions](https://code.claude.com/docs/en/permissions) |
| Best Practices | ✅ Done | 1 | [best-practices](https://code.claude.com/docs/en/best-practices) |
| Skills (Slash Commands) | ✅ Done | 2 | [skills](https://code.claude.com/docs/en/skills) |
| Subagents | ✅ Done | 2 | [sub-agents](https://code.claude.com/docs/en/sub-agents) |
| Hooks | ✅ Done | 2 | [hooks](https://code.claude.com/docs/en/hooks) |
| MCP | ✅ Done | 2 | [mcp](https://code.claude.com/docs/en/mcp) |
| Plugins | ✅ Done | 2 | [plugins](https://code.claude.com/docs/en/plugins) |
| Agent Teams | ✅ Done | 3 | [agent-teams](https://code.claude.com/docs/en/agent-teams) |
| Headless / Agent SDK | ✅ Done | 3 | [headless](https://code.claude.com/docs/en/headless) |
| Common Workflows | ✅ Done | 3 | [common-workflows](https://code.claude.com/docs/en/common-workflows) |
| Platform & Integration | ✅ Done | 4 | [overview](https://code.claude.com/docs/en/overview) |
| CI/CD | ✅ Done | 4 | [github-actions](https://code.claude.com/docs/en/github-actions) |
| Slack Integration | ✅ Done | 4 | [slack](https://code.claude.com/docs/en/slack) |

---

# Part 1: Basic Setup (What to Know First)

---

## 1. Memory / CLAUDE.md

> Docs: https://code.claude.com/docs/en/memory

### Key concepts

Claude Code has two kinds of persistent memory:
- **CLAUDE.md file**: Instructions, rules, and preferences you write and manage yourself
- **Auto Memory**: Claude automatically stores project patterns, key commands, and preferences

### Memory hierarchy (6 levels)

| Memory type | Location | Purpose | Scope |
|------------|----------|---------|-------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux: `/etc/claude-code/CLAUDE.md` | Org-wide coding standards, security policy | Organization |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Project architecture, coding rules | Team (version controlled) |
| **Project rules** | `./.claude/rules/*.md` | Per-module/path rules | Team (version controlled) |
| **User** | `~/.claude/CLAUDE.md` | Personal code style preferences | Self only (all projects) |
| **Project local** | `./CLAUDE.local.md` | Per-project local settings (e.g. sandbox URL) | Self only (current project) |
| **Auto memory** | `~/.claude/projects/<project>/memory/` | Claude auto-memory, learned content | Self only (per project) |

### Auto Memory structure

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # Concise index — loaded at session start (first 200 lines)
  debugging.md       # Detailed debugging patterns (read when needed)
  api-conventions.md # API design decisions (read when needed)
```

- First 200 lines of `MEMORY.md` are injected into the system prompt
- Topic files are not loaded at start; Claude reads them when needed
- Toggle via `/memory` command
- Disable:
```json
// ~/.claude/settings.json
{ "autoMemoryEnabled": false }
```
```bash
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1  # Force disable
```

### CLAUDE.md Import (`@` syntax)

```markdown
See @README for project overview and @package.json for available npm commands.
# Additional instructions
- git workflow @docs/git-instructions.md
```
- Relative and absolute paths both supported
- Up to 5 levels of recursive import
- Not evaluated inside code blocks or inline code

### Modular Rules (`.claude/rules/`)

```
your-project/
  .claude/
    CLAUDE.md
    rules/
      code-style.md
      testing.md
      security.md
```

Path-conditional rules (YAML frontmatter):
```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API development rules
- Require input validation on all API endpoints
```

Supported patterns:
| Pattern | Matches |
|---------|---------|
| `**/*.ts` | TypeScript files in any subdirectory |
| `src/**/*` | All files under src/ |
| `*.md` | Markdown files at project root |
| `src/components/*.tsx` | React components in that directory |

Brace expansion: `src/**/*.{ts,tsx}`

User-level rules: `~/.claude/rules/` — applied to all projects (loaded before project rules)

### Key commands

| Command | Purpose |
|---------|---------|
| `/init` | Analyze codebase → detect build system, test framework, code patterns |
| `/memory` | Toggle Auto Memory |

### Load CLAUDE.md from additional directories

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

---

## 2. Permissions

> Docs: https://code.claude.com/docs/en/permissions

### Default approval by tool type

| Tool type | Examples | Approval required | "Don't ask again" behavior |
|-----------|----------|-------------------|----------------------------|
| Read-only | File reads, Grep | No | N/A |
| Bash commands | Shell execution | Yes | Persisted per project dir + command |
| File edits | Edit/Write | Yes | Until session end |

### Five permission modes

| Mode | Description |
|------|-------------|
| `default` | Standard: ask on first use |
| `acceptEdits` | Auto-approve file edits (for the session) |
| `plan` | Plan Mode: analysis only, no edits |
| `dontAsk` | Only pre-approved items in `/permissions` allowed; rest auto-denied |
| `bypassPermissions` | Skip all approvals (safe environment required) |

### Permission rule syntax

**Match entire tool**:
```json
{ "allow": ["Bash", "WebFetch", "Read"] }
```

**Fine-grained**:
| Rule | Effect |
|------|--------|
| `Bash(npm run build)` | Exact command match |
| `Read(./.env)` | Match reading .env file |
| `WebFetch(domain:example.com)` | Match requests to that domain |

**Wildcard patterns**:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git commit *)",
      "Bash(git * main)",
      "Bash(* --version)"
    ],
    "deny": [
      "Bash(git push *)"
    ]
  }
}
```

### Path pattern syntax

| Pattern | Meaning | Example | Matches |
|---------|---------|---------|---------|
| `//path` | Filesystem absolute path | `Read(//Users/alice/secrets/**)` | `/Users/alice/secrets/**` |
| `~/path` | Home directory relative | `Read(~/Documents/*.pdf)` | `/Users/alice/Documents/*.pdf` |
| `/path` | Project root relative | `Edit(/src/**/*.ts)` | `<project root>/src/**/*.ts` |
| `path` or `./path` | Current directory relative | `Read(*.env)` | `<cwd>/*.env` |

### MCP / Task permissions

```json
{
  "permissions": {
    "allow": ["mcp__puppeteer"],
    "deny": ["mcp__puppeteer__puppeteer_navigate", "Task(Explore)"]
  }
}
```
- `mcp__puppeteer`: match all tools of the puppeteer server
- `mcp__puppeteer__puppeteer_navigate`: match that specific tool only
- `Task(Explore)`: block that specific subagent

### Managed settings

| Setting | Description |
|---------|-------------|
| `disableBypassPermissionsMode` | Block bypassPermissions mode with `"disable"` |
| `allowManagedPermissionRulesOnly` | Block user/project permission rule definitions |
| `allowManagedHooksOnly` | Block user/project/plugin hook loading |
| `allowManagedMcpServersOnly` | Only allow MCP servers from managed config |
| `allow_remote_sessions` | Control Remote Control and web session access |

### Example configurations

**Developer-friendly (fast iteration)**:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(npx prettier *)",
      "Edit(/src/**)",
      "Read"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(rm -rf *)"
    ]
  }
}
```

**Security-hardened (production)**:
```json
{
  "permissions": {
    "defaultMode": "dontAsk",
    "allow": [
      "Read(/src/**)",
      "Bash(npm test *)"
    ],
    "deny": [
      "Bash(git push *)",
      "Edit(//.env*)",
      "Bash(curl *)",
      "WebFetch"
    ]
  }
}
```

---

## 3. Best Practices

> Docs: https://code.claude.com/docs/en/best-practices

### Core principle

> Context window fills quickly; the fuller it is, the worse performance. It's the most important resource.

### Five principles for effective use

#### Principle 1: Provide verification criteria

| Strategy | Before | After |
|----------|--------|-------|
| Verification criteria | "Implement an email validation function" | "Write validateEmail. user@example.com→true, invalid→false. Run tests after implementing" |
| Visual verification for UI | "Make the dashboard look better" | "[Attach screenshot] Implement this design. Take a screenshot to compare" |
| Root cause fix | "Build is failing" | "Build fails with this error: [paste error]. Fix and confirm build succeeds" |

#### Principle 2: Explore → Plan → Implement → Commit (4 steps)

1. **Explore** (Plan Mode) — Read files, answer questions, no changes
2. **Plan** (Plan Mode) — Write a detailed implementation plan
3. **Implement** (Normal Mode) — Write code, verify against plan
4. **Commit** (Normal Mode) — Commit with descriptive message, create PR

#### Principle 3: Effective CLAUDE.md

| Include | Exclude |
|---------|---------|
| Bash commands Claude can't infer | Things obvious from reading code |
| Code style rules that differ from defaults | Standard conventions Claude already knows |
| Test instructions | Full API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Frequently changing info |
| Project-specific architecture decisions | Long explanations or tutorials |
| Dev environment quirks | Per-file codebase descriptions |
| Common pitfalls | Obvious things like "write clean code" |

Example:
```markdown
# Code style
- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible

# Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, not the whole test suite, for performance
```

#### Principle 4: Actively manage context

| Command | Purpose |
|---------|---------|
| `/clear` | Clear context between unrelated tasks |
| `/compact <instructions>` | Controlled compaction (can include instructions) |
| `Esc + Esc` or `/rewind` | Rewind from checkpoint |
| CLAUDE.md custom | Customize compaction behavior |

#### Principle 5: Have Claude interview you

```text
I want to build [brief description]. Interview me in detail using the AskUserQuestion tool.
Ask about technical implementation, UI/UX, edge cases, concerns, and tradeoffs.
Keep interviewing until we've covered everything, then write a complete spec to SPEC.md.
```

### Good vs bad prompts

| Bad prompt | Good prompt |
|------------|-------------|
| "Implement email validation" | "Write validateEmail with test cases; run tests after implementing" |
| "Improve the dashboard" | "[Screenshot] Implement this design; compare with screenshot" |
| "Build is failing" | "Failing with this error: [error]. Fix and confirm build succeeds" |
| "Refactor this code" | "Refactor utils.js to ES2024; keep same behavior; run tests" |

### Common failure patterns

| Pattern | Fix |
|---------|-----|
| Kitchen sink session (everything in one session) | Use `/clear` between unrelated tasks |
| Repeated fix requests (2+ times) | `/clear` and restart with a better prompt |
| Bloated CLAUDE.md | Prune ruthlessly |
| Trust without verification | Always provide verification criteria |
| Endless exploration | Limit scope or use subagents |

### Parallel sessions (Writer/Reviewer pattern)

| Session A (Writer) | Session B (Reviewer) |
|---|---|
| `Implement a rate limiter for our API endpoints` | |
| | `Review the rate limiter implementation in @src/middleware/rateLimiter.ts` |
| `Here's the review feedback: [B result]. Address these issues.` | |

### Fan Out (bulk work)

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

---

# Part 2: Extended features (learn one by one)

---

## 4. Skills (slash commands)

> Docs: https://code.claude.com/docs/en/skills

### Key concepts
- Custom commands defined in `SKILL.md` files
- Replaces legacy `.claude/commands/` (backward compatible)
- Based on [Agent Skills](https://agentskills.io) open standard

### Storage locations (priority order)
| Location | Path | Scope |
|----------|------|-------|
| Enterprise | managed settings | Organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All my projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

### SKILL.md structure
```yaml
---
name: skill-name
description: When to use this skill (used by Claude for auto-invocation)
disable-model-invocation: true  # Prevent Claude from auto-invoking (manual only)
user-invocable: false           # Hidden from / menu (Claude-only)
allowed-tools: Read, Grep, Glob # Tools allowed when this skill runs
context: fork                   # Run in isolated subagent
agent: Explore                  # Agent type when context is fork
model: sonnet                   # Model used when this skill runs
---

Skill instructions (markdown)...
```

### Frontmatter fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Slash command name. Lowercase/digits/hyphen (max 64 chars). Default: directory name |
| `description` | Recommended | Used by Claude to decide auto-invocation → **write it well** |
| `argument-hint` | No | Autocomplete hint. e.g. `[issue-number]` |
| `disable-model-invocation` | No | `true` = Claude cannot auto-run. Default: `false` |
| `user-invocable` | No | `false` = hidden from `/` menu. Default: `true` |
| `allowed-tools` | No | Tools allowed without approval when skill is active |
| `model` | No | Model used when this skill runs |
| `context` | No | Set to `fork` to run in subagent |
| `agent` | No | Agent type when `context: fork` |
| `hooks` | No | Hooks scoped to this skill's lifecycle |

### Argument passing
```yaml
# $ARGUMENTS - full argument string
# $ARGUMENTS[N] or $N - Nth argument (0-based)
# ${CLAUDE_SESSION_ID} - current session ID

Fix GitHub issue $ARGUMENTS following our coding standards.
Migrate the $0 component from $1 to $2.
```

### Dynamic context injection (`` !`command` ``)
```yaml
## PR info
- diff: !`gh pr diff`
- comments: !`gh pr view --comments`
- changed files: !`gh pr diff --name-only`
```
Run shell command before skill execution and inject result into prompt.

### Supported file structure
```
my-skill/
├── SKILL.md        # Required
├── template.md     # Optional
├── examples/
└── scripts/
    └── validate.sh
```

### Invocation control matrix
| Setting | User invocation | Claude invocation | Context load |
|---------|-----------------|-------------------|-------------|
| Default | Yes | Yes | Description always loaded |
| `disable-model-invocation: true` | Yes | No | Not loaded |
| `user-invocable: false` | No | Yes | Description always loaded |

### Running in subagent

| Method | System prompt | Task | Additional load |
|--------|---------------|------|-----------------|
| Skill + `context: fork` | From agent type | SKILL.md content | CLAUDE.md |
| Subagent + `skills` field | Subagent body | Claude delegation message | Preloaded skills + CLAUDE.md |

### Skill budget

Description loaded up to 2% of context window (fallback: 16,000 chars). Override:
```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=32000
```

### Practical examples

#### `/ship` — Commit + PR in one command

```yaml
---
name: ship
description: Commit current changes and create a PR. Use when task is done.
---
## Current changes
!`git diff --staged`
!`git diff`

Analyze the changes above and:
1. Write a commit message summarizing the changes (English, ≤50 chars)
2. Run git add -A && git commit
3. Write PR title/body (in your preferred language)
4. Run gh pr create
```

#### `/review` — Read PR diff and post review comments

```yaml
---
name: review
description: PR code review. Pass PR number as /review 123.
argument-hint: "[pr-number]"
---
## PR #$ARGUMENTS review request

Changed files:
!`gh pr diff $ARGUMENTS --name-only`

Full diff:
!`gh pr diff $ARGUMENTS`

Existing comments:
!`gh pr view $ARGUMENTS --comments`

Analyze for bugs, security, performance, and improvements, then post comments on the PR.
```

---

## 5. Subagents

> Docs: https://code.claude.com/docs/en/sub-agents

### Key concepts
- Specialized agents with their own context window
- Avoid polluting the main conversation context
- Run in a constrained environment with specific tools/permissions

### Built-in agents
| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| Explore | Haiku (fast) | Read-only | File exploration, code search |
| Plan | Inherit | Read-only | Plan mode research |
| general-purpose | Inherit | Full | Complex multi-step tasks |
| Bash | Inherit | Terminal commands | Separate context |
| statusline-setup | Sonnet | `/statusline` setup | Status line setup |
| Claude Code Guide | Haiku | Feature Q&A | Claude Code questions |

### Creating agents
- `/agents` — Create/manage via interactive UI
- `claude agents` — List from CLI
- Create file directly: `.claude/agents/<name>.md`
- Session-scoped via `--agents` flag

### Agent file structure
```markdown
---
name: code-reviewer
description: Expert code reviewer. Invoke right after code changes.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
maxTurns: 50
memory: user
background: false
isolation: worktree
---

System prompt (markdown)...
```

### Scope priority

| Location | Scope | Priority |
|----------|-------|----------|
| `--agents` CLI flag | Current session | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All projects | 3 |
| Plugin `agents/` | Where plugin is enabled | 4 (lowest) |

### CLI-defined subagent

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

### Frontmatter fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier |
| `description` | Yes | Used by Claude to decide when to delegate |
| `tools` | No | Tool allowlist (omit = inherit all) |
| `disallowedTools` | No | Tool denylist |
| `model` | No | `sonnet`, `opus`, `haiku`, `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Max execution turns |
| `skills` | No | Skills to inject at start |
| `mcpServers` | No | Available MCP servers |
| `hooks` | No | Lifecycle hooks |
| `memory` | No | `user`, `project`, `local` |
| `background` | No | `true` = always run in background |
| `isolation` | No | `worktree` for git worktree isolation |

### tools field details

Omit to inherit all tools from parent Claude. Specify for allowlist behavior.

```yaml
# Read-only (file exploration only)
tools: Read, Grep, Glob

# Include writes
tools: Read, Grep, Glob, Edit, Write

# Include shell execution
tools: Read, Grep, Glob, Edit, Write, Bash

# Only specific Bash commands
tools: Read, Bash(git commit *), Bash(npm test)

# Include MCP tools
tools: Read, Grep, Glob, Bash, mcp__github

# Only allow spawning specific agents
tools: Task(worker, researcher), Read, Bash
```

Exclude specific tools with `disallowedTools`:
```yaml
disallowedTools: Bash, Write  # All others allowed
```

### Skills preload

At agent start, **full content** of specified skills is **auto-injected** into context.

```yaml
---
name: my-agent
description: ...
tools: Read, Grep, Glob
skills:
  - ship      # Full .claude/skills/ship/SKILL.md injected
  - review    # Full .claude/skills/review/SKILL.md injected
---
System prompt...
```

Example: Give `security-reviewer` the review skill so it knows how to read PR diff:
```yaml
---
name: security-reviewer
description: Expert security vulnerability reviewer
tools: Read, Grep, Glob
model: opus
skills:
  - review
---
Analyze against OWASP Top 10.
```

### Persistent Memory
```yaml
memory: user  # ~/.claude/agent-memory/<name>/
```

| Scope | Location | When used |
|-------|----------|-----------|
| `user` | `~/.claude/agent-memory/<name>/` | Shared learning across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-scoped, shareable |
| `local` | `.claude/agent-memory-local/<name>/` | Project-scoped, excluded from VCS |

### Foreground vs background
- **Foreground**: Blocks until done; permission prompts apply
- **Background**: Runs in parallel; permissions must be pre-approved before start (Ctrl+B)

### Subagent spawn limits

```yaml
# Only allow spawning specific agents
tools: Task(worker, researcher), Read, Bash
```

```json
// Block specific agents
{ "permissions": { "deny": ["Task(Explore)", "Task(my-custom-agent)"] } }
```

### Auto-compaction

Triggers at ~95% capacity. Override:
```bash
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50
```

### When to use
- When heavy output would pollute main context
- When specific tool/permission limits are needed
- When the task is self-contained

### Example: Multi-agent parallel PR review

Define three agent files; a single request runs them all in parallel.

```yaml
# .claude/agents/security-reviewer.md
---
name: security-reviewer
description: Expert security reviewer. Invoke when security review is needed after code changes.
tools: Read, Grep, Glob
model: opus
---
Analyze code for vulnerabilities against OWASP Top 10.
Focus on SQL injection, XSS, auth/authz issues.
```

```yaml
# .claude/agents/perf-reviewer.md
---
name: perf-reviewer
description: Performance optimization expert. Detects N+1 queries, memory leaks, unnecessary renders.
tools: Read, Grep, Glob
model: sonnet
---
Analyze performance bottlenecks.
Look for N+1 queries, unnecessary loops, missing caching, memory waste.
```

```yaml
# .claude/agents/test-validator.md
---
name: test-validator
description: Test coverage reviewer. Verifies new code has sufficient tests.
tools: Read, Grep, Glob, Bash
model: haiku
---
Verify tests adequately cover the changed code.
Check for missing edge-case and error-handling tests.
```

Usage:
```
Review this PR from security, performance, and test coverage in parallel
→ security-reviewer + perf-reviewer + test-validator run in parallel
```

---

## 6. Hooks

> Docs: https://code.claude.com/docs/en/hooks

### Key concepts
- Automation scripts that run **deterministically** when specific events occur
- Run the same way every time without LLM judgment (key difference from Skills/Subagents)
- Three types: command (shell), prompt (single-turn LLM), agent (multi-turn LLM)

### Full event list (17)

| Event | When it fires | matcher target |
|--------|----------|-------------|
| `SessionStart` | Session start/resume | `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | Session end | `clear`, `logout`, `prompt_input_exit` |
| `UserPromptSubmit` | When prompt submitted (before processing) | — |
| `PreToolUse` | Before tool runs (can block) | Tool name: `Bash`, `Edit\|Write`, `mcp__.*` |
| `PermissionRequest` | When permission dialog shown | — |
| `PostToolUse` | After tool succeeds | Tool name |
| `PostToolUseFailure` | After tool fails | Tool name |
| `Stop` | When Claude response completes | — |
| `Notification` | When notification sent | `permission_prompt`, `idle_prompt` |
| `SubagentStart` | Subagent starts | Agent type |
| `SubagentStop` | Subagent completes | — |
| `TeammateIdle` | Teammate goes idle | — |
| `TaskCompleted` | Task marked complete | — |
| `ConfigChange` | Config file changed | `user_settings`, `project_settings`, `skills` |
| `PreCompact` | Before context compaction | `manual`, `auto` |
| `WorktreeCreate` | Worktree created | — |
| `WorktreeRemove` | Worktree removed | — |

### Exit code behavior

| Exit code | Behavior |
|-----------|----------|
| `0` | Pass. For `UserPromptSubmit`/`SessionStart`, stdout is added to context |
| `2` | Block action. stderr message is sent to Claude as feedback |
| Other | Proceed. stderr only logged |

### Hook types

| Type | Description |
|------|-------------|
| `command` | Run shell command |
| `prompt` | Single-turn LLM evaluation |
| `agent` | Multi-turn verification (tool access) |

### Storage locations

| Location | Scope | Shared |
|----------|-------|--------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Current project | Yes (repo commit) |
| `.claude/settings.local.json` | Current project | No (gitignore) |
| Managed policy settings | Organization | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/Agent frontmatter | When skill/agent active | Yes |

### Practical examples

#### 1. Run tests on file edit (Claude sees result immediately)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "cd $CLAUDE_PROJECT_DIR && npm test --passWithNoTests 2>&1 | tail -20"
          }
        ]
      }
    ]
  }
}
```
Each time Claude edits a file, test output is injected into context.
If tests fail, Claude sees it and can fix automatically.

#### 2. Auto-verify on task completion (agent type)

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Run npm test. If any tests fail, report exactly what needs to be fixed.",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```
After each Claude response, run tests and send feedback to Claude on failure.

#### 3. Block editing protected files

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/")
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
    exit 2
  fi
done
exit 0
```

#### 4. Auto-format after edit

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

#### 5. Re-inject context after compact

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing.'"
          }
        ]
      }
    ]
  }
}
```

#### 6. macOS notification

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

#### 7. PreToolUse structured output (tool control)

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep for better performance"
  }
}
```
Options: `"allow"`, `"deny"`, `"ask"`

---

## 7. MCP (Model Context Protocol)

> Docs: https://code.claude.com/docs/en/mcp

### Key concepts
- Open standard for AI–tool integration
- Connect external services (Jira, Slack, Google Drive, DB, etc.) to Claude
- Per-subagent MCP server configuration

### Usage examples

```
# Implement from a single GitHub issue
@github:issue://234 implement this issue

# Natural-language DB query (with postgres MCP)
How many users signed up yesterday but haven't completed onboarding?

# Jira + GitHub + Slack in one flow
Read @jira:issue://ENG-1234, implement, open a PR, then notify @slack:channel://eng-team

# MCP prompt as slash command
/mcp__github__create_issue "500 error on login button click" high
```

### Three transport types

#### HTTP (recommended)
```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

#### SSE (deprecated)
```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

#### Local Stdio
```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

### Three scopes

| Scope | Storage | Purpose |
|-------|---------|--------|
| `local` (default) | `~/.claude.json` (under project path) | Personal, current project only |
| `project` | `.mcp.json` (project root) | Team shared (version controlled) |
| `user` | `~/.claude.json` | Personal, all projects |

```bash
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

### Management commands

```bash
claude mcp list          # List all
claude mcp get github    # Server details
claude mcp remove github # Remove
/mcp                     # Inside Claude Code
```

### `.mcp.json` config example

```json
{
  "mcpServers": {
    "shared-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

Environment variable expansion:
```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

### Add via JSON

```bash
claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'
```

### Import from Claude Desktop

```bash
claude mcp add-from-claude-desktop
```

### Use Claude Code as MCP server

```bash
claude mcp serve
```

Claude Desktop config:
```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

### OAuth authentication

```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

CI environment:
```bash
MCP_CLIENT_SECRET=your-secret claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

### Resource reference (`@` syntax)

```
> @github:issue://123 analyze and suggest fixes
> Compare @postgres:schema://users with @docs:file://database/user-model
```

### Use MCP prompts as commands

```
> /mcp__github__list_prs
> /mcp__github__pr_review 456
> /mcp__jira__create_issue "Bug in login flow" high
```

### Output limits

| Setting | Default |
|---------|---------|
| Warning threshold | 10,000 tokens |
| Max output | 25,000 tokens |
| Custom | `export MAX_MCP_OUTPUT_TOKENS=50000` |

### Tool Search

| Value | Behavior |
|-------|----------|
| `auto` | Enable when MCP tools exceed 10% of context (default) |
| `auto:<N>` | Custom threshold ratio |
| `true` | Always on |
| `false` | Off; all tools loaded upfront |

```bash
ENABLE_TOOL_SEARCH=auto:5 claude
ENABLE_TOOL_SEARCH=false claude
```

### Managed MCP settings

File locations:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux: `/etc/claude-code/managed-mcp.json`

```json
{
  "mcpServers": {
    "github": { "type": "http", "url": "https://api.githubcopilot.com/mcp/" },
    "sentry": { "type": "http", "url": "https://mcp.sentry.dev/mcp" }
  }
}
```

Allowlist/Denylist:
```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverUrl": "https://mcp.company.com/*" }
  ],
  "deniedMcpServers": [
    { "serverName": "dangerous-server" }
  ]
}
```
Denylist always overrides allowlist. URL patterns support `*` wildcard.

---

## 8. Plugins

> Docs: https://code.claude.com/docs/en/plugins

### Key concepts
- Packaging unit for Skills + Subagents + Hooks + MCP for distribution
- Choose Standalone (`.claude/` directly) or Plugin (packaged)

### Standalone vs Plugin

| Approach | Skill name | Best for |
|----------|------------|----------|
| Standalone (`.claude/` dir) | `/hello` | Personal workflow, project-only, quick experiments |
| Plugin (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing, distribution, versioning, reuse |

### Directory structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (required)
├── commands/                # Skills (markdown files)
├── agents/                  # Custom agent definitions
├── skills/                  # Agent Skills (SKILL.md)
├── hooks/
│   └── hooks.json           # Event handlers
├── .mcp.json                # MCP server config
├── .lsp.json                # LSP server config
└── settings.json            # Default settings when plugin enabled
```

### plugin.json manifest

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

### Local testing

```bash
claude --plugin-dir ./my-plugin
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### LSP server config (`.lsp.json`)

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

### Default settings (`settings.json`)

```json
{
  "agent": "security-reviewer"
}
```

### MCP server in plugin

`.mcp.json`:
```json
{
  "database-tools": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
    "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
    "env": { "DB_URL": "${DB_URL}" }
  }
}
```

Or inline in `plugin.json`:
```json
{
  "name": "my-plugin",
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"]
    }
  }
}
```

### Standalone → Plugin migration

```bash
mkdir -p my-plugin/.claude-plugin
cp -r .claude/commands my-plugin/
cp -r .claude/agents my-plugin/
cp -r .claude/skills my-plugin/
mkdir my-plugin/hooks
```

Hooks migration — copy from `.claude/settings.json` to `my-plugin/hooks/hooks.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npm run lint:fix" }]
      }
    ]
  }
}
```

### Official marketplace plugins

Install via `/plugin` → Discover tab or:
```bash
/plugin install plugin-name@claude-plugins-official
```

#### Code Intelligence (LSP) — Real-time errors per language

When installed, Claude **auto-detects type/import errors** after file edits and can fix them in the same turn.

| Plugin | Language | Required binary |
|---------|------|-------------|
| `typescript-lsp` | TypeScript/JavaScript | `typescript-language-server` |
| `pyright-lsp` | Python | `pyright-langserver` |
| `rust-analyzer-lsp` | Rust | `rust-analyzer` |
| `gopls-lsp` | Go | `gopls` |
| `jdtls-lsp` | Java | `jdtls` |
| `kotlin-lsp` | Kotlin | `kotlin-language-server` |
| `clangd-lsp` | C/C++ | `clangd` |
| `swift-lsp` | Swift | `sourcekit-lsp` |
| `php-lsp` | PHP | `intelephense` |

#### External Integrations (MCP bundles)

Connect without manual MCP setup:

| Category | Plugins |
|----------|---------|
| Source control | `github`, `gitlab` |
| Project management | `atlassian` (Jira+Confluence), `asana`, `linear`, `notion` |
| Design | `figma` |
| Infrastructure | `vercel`, `firebase`, `supabase` |
| Communication | `slack` |
| Monitoring | `sentry` |

#### Development Workflows

| Plugin | Description |
|--------|-------------|
| `commit-commands` | git commit/push/PR workflow |
| `pr-review-toolkit` | PR review–focused agent |
| `agent-sdk-dev` | Claude Agent SDK dev tools |
| `plugin-dev` | Plugin authoring tools |

#### Output Styles

| Plugin | Description |
|--------|-------------|
| `explanatory-output-style` | Explains why code was chosen |
| `learning-output-style` | Interactive mode for learners |

### Marketplace management

```bash
# Official marketplace is auto-registered. Add others:
/plugin marketplace add anthropics/claude-code   # GitHub repo
/plugin marketplace add https://example.com/marketplace.json

# List / update / remove
/plugin marketplace list
/plugin marketplace update marketplace-name
/plugin marketplace remove marketplace-name
```

### Plugin management

```bash
/plugin install typescript-lsp@claude-plugins-official
/plugin install typescript-lsp@claude-plugins-official --scope project  # Team shared

/plugin disable plugin-name@marketplace-name
/plugin enable  plugin-name@marketplace-name
/plugin uninstall plugin-name@marketplace-name
```

Scopes:
- `user` (default) — All my projects
- `project` — Team shared (written to `.claude/settings.json`)
- `local` — This project only, not shared

---

# Part 3: Advanced features

---

## 9. Agent Teams (experimental)

> Docs: https://code.claude.com/docs/en/agent-teams
> Enable: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

### Key concepts
- Teammates **communicate directly** with each other (key difference from Subagents)
- Self-coordination via shared task list
- Each teammate has its own context window

### Subagents vs Agent Teams

| | Subagents | Agent Teams |
|---|---|---|
| Context | Own window; returns result only | Own window; fully independent |
| Communication | Reports to main only | Teammates message each other |
| Coordination | Main manages | Shared task list, self-coordinated |
| Use case | Focused work where only result matters | Complex work needing discussion/collab |
| Token cost | Lower | Higher |

### Components

| Component | Role |
|-----------|------|
| Team lead | Create team, spawn teammates, coordinate |
| Teammates | Independent Claude Code instances |
| Task list | Shared work list (claim/complete) |
| Mailbox | Inter-agent messaging |

### Enabling

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Display modes

| Mode | Description |
|------|-------------|
| **in-process** | Switch teammates with Shift+Down in main terminal |
| **split panes** | Split panes via tmux or iTerm2 |

```json
{ "teammateMode": "in-process" }
```
```bash
claude --teammate-mode in-process
```

### Storage

- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Strong use cases
- Parallel code review (security / perf / tests)
- Bug debugging with competing hypotheses
- Frontend/backend/test work in parallel

### Limitations (experimental)
- In-process teammates not restored on session resume
- Task state may be delayed
- Shutdown can be slow
- One team per session
- No nested teams (teammate can't create another team)
- Leader is fixed (cannot change)
- Permissions set at spawn
- Split pane requires tmux or iTerm2

---

## 10. Headless / Agent SDK

> Docs: https://code.claude.com/docs/en/headless

### Key concepts
- Programmatic execution via `-p` flag (non-interactive)
- Use in CI/CD, scripts, pipelines
- Structured output (JSON, stream) supported

### Basic usage

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

### Structured output

```bash
# Plain text (default)
claude -p "Summarize this project" --output-format text

# JSON with metadata
claude -p "Summarize this project" --output-format json

# Structured with JSON schema
claude -p "Extract the main function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'

# Extract specific field
claude -p "Summarize this project" --output-format json | jq -r '.result'
```

### Streaming response

```bash
claude -p "Explain recursion" --output-format stream-json --verbose --include-partial-messages

# Filter text deltas only
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

### Auto-approve tools (`--allowedTools`)

```bash
claude -p "Run the test suite and fix any failures" \
  --allowedTools "Bash,Read,Edit"
```

### Commit automation example

```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

### Customize system prompt

```bash
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

### Continue session

```bash
# Resume most recent session
claude -p "Review this codebase for performance issues"
claude -p "Now focus on the database queries" --continue

# Resume specific session
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Unix pipe patterns

```bash
# Analyze build error
cat build-error.txt | claude -p 'concisely explain the root cause' > output.txt

# Security review
git diff main --name-only | claude -p "review these changed files for security issues"

# Use in npm script
# package.json
{
  "scripts": {
    "lint:claude": "claude -p 'you are a linter. please look at the changes vs. main and report any issues related to typos.'"
  }
}
```

### CI/CD usage examples

```bash
# Translation automation
claude -p "translate new strings into French and raise a PR for review"

# PR security review
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

---

## 11. Common Workflows

> Docs: https://code.claude.com/docs/en/common-workflows

### Five main workflows

#### 1. Understand codebase

```
> give me an overview of this codebase
> explain the main architecture patterns used here
> what are the key data models?
> find the files that handle user authentication
> trace the login process from front-end to database
```

#### 2. Fix bugs

```
> I'm seeing an error when I run npm test
> suggest a few ways to fix the @ts-ignore in user.ts
> update user.ts to add the null check you suggested
```

#### 3. Refactoring

```
> find deprecated API usage in our codebase
> suggest how to refactor utils.js to use modern JavaScript features
> refactor utils.js to use ES2024 features while maintaining the same behavior
> run tests for the refactored code
```

#### 4. Write tests

Prompts with verification criteria are key:
```
> write tests for the auth module. run them after implementation.
> add edge case tests for null/undefined inputs in validator.ts
```

#### 5. Create PR

```
> /commit-push-pr
> create a pr
```
Session created via `gh pr create` is linked to the PR. Resume with `claude --from-pr <number>`.

### Plan Mode

```bash
# Start from CLI
claude --permission-mode plan

# Toggle during session: Shift+Tab
# Open plan in text editor: Ctrl+G
```

Set as default:
```json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

### Extended Thinking settings

| Scope | How to set | Details |
|-------|------------|---------|
| Effort level | `/model` or `CLAUDE_CODE_EFFORT_LEVEL` | low, medium, high (default) |
| Toggle shortcut | `Option+T` (macOS) / `Alt+T` (Win/Linux) | Toggle for current session |
| Global default | `/config` | Default for all projects |
| Token budget limit | `MAX_THINKING_TOKENS` env var | Cap at specific tokens |

### Image analysis

- Drag and drop into Claude Code window
- Paste with `Ctrl+V`
- By path: "Analyze this image: /path/to/image.png"

### Session management

```bash
claude --continue    # Resume most recent session
claude --resume      # Pick from recent sessions
claude --from-pr 123 # Resume session linked to PR
```

Session picker shortcuts:
| Shortcut | Action |
|----------|--------|
| Up/Down | Navigate sessions |
| Right/Left | Expand/collapse group |
| Enter | Select and resume |
| P | Session preview |
| R | Rename session |
| / | Search filter |
| A | Toggle current dir / full project |
| B | Current branch filter |

### Git Worktree parallel sessions

```bash
claude --worktree feature-auth
claude --worktree bugfix-123
claude --worktree  # Auto-generated name
```

- Created at `<repo>/.claude/worktrees/<name>`
- Branches from default remote branch
- Subagent: use `isolation: worktree` in frontmatter

### `@` syntax reference

```
> explain the main architecture in @src/index.ts
> review @src/middleware/rateLimiter.ts
```

### Notification hook matchers

| matcher | When it fires |
|---------|----------------|
| `permission_prompt` | Claude needs approval |
| `idle_prompt` | Claude done, waiting for next input |
| `auth_success` | Auth completed |
| `elicitation_dialog` | Claude is asking a question |

---

# Part 4: Platform & integration

---

## 12. Platform

> Docs: https://code.claude.com/docs/en/overview

### Available surfaces

| Goal | Best option |
|------|-------------|
| Continue local session on another device | Remote Control |
| Start locally → continue on mobile | Web or Claude iOS app |
| Automate PR review, issue triage | GitHub Actions / GitLab CI/CD |
| Slack bug report → PR | Slack |
| Live web app debugging | Chrome |
| Build custom agents | Agent SDK |

### Installation

```bash
# macOS, Linux, WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Homebrew
brew install --cask claude-code

# WinGet
winget install Anthropic.ClaudeCode
```

### IDE integration

| IDE | How to install |
|-----|----------------|
| **VS Code** | Search Extensions for "Claude Code" → Command Palette > "Open in New Tab" |
| **JetBrains** | Install from JetBrains Marketplace (IntelliJ, PyCharm, WebStorm, etc.) |
| **Desktop** | Download for macOS (Intel + Apple Silicon), Windows (x64, ARM64) |

### Web

Run in browser at [claude.ai/code](https://claude.ai/code). No local install needed.

### Cross-surface features

| Feature | Description |
|---------|-------------|
| `/teleport` | Pull Web/iOS session into terminal |
| `/desktop` | Hand off terminal session to Desktop app |
| `@Claude` (Slack) | Get PR from chat |
| Remote Control | Continue on phone |

All surfaces share the same CLAUDE.md, settings, and MCP servers.

### Doc links

| Feature | Docs |
|------|------|
| Remote Control | [remote-control](https://code.claude.com/docs/en/remote-control) |
| Web | [claude-code-on-the-web](https://code.claude.com/docs/en/claude-code-on-the-web) |
| Chrome | [chrome](https://code.claude.com/docs/en/chrome) |
| Desktop | [desktop](https://code.claude.com/docs/en/desktop) |

---

## 13. CI/CD

> GitHub Actions: https://code.claude.com/docs/en/github-actions
> GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd
> Action repo: https://github.com/anthropics/claude-code-action

### GitHub Actions

#### Key concepts

- `@claude` mention in PR/issue for code analysis, PR creation, feature implementation, bug fixes
- Follows CLAUDE.md guidelines and existing code patterns
- Can build custom automation workflows on Agent SDK
- Default model is Sonnet; for Opus use `--model claude-opus-4-6`

#### Quick setup

```bash
# Run in Claude Code terminal (easiest)
/install-github-app
```
> Repo admin required. GitHub App requests Read & Write on Contents, Issues, Pull requests.

**Manual setup**:
1. Install [Claude GitHub App](https://github.com/apps/claude)
2. Add `ANTHROPIC_API_KEY` to repo Secrets
3. Copy [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml) to `.github/workflows/`

#### Basic workflow

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          # Auto-respond to @claude mentions
```

#### Workflow using Skills

```yaml
name: Code Review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "/review"
          claude_args: "--max-turns 5"
```

#### Scheduled automation workflow

```yaml
name: Daily Report
on:
  schedule:
    - cron: "0 9 * * *"
jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Generate a summary of yesterday's commits and open issues"
          claude_args: "--model opus"
```

#### Action parameters (v1)

| Parameter | Description | Required |
|-----------|-------------|----------|
| `prompt` | Instruction for Claude (text or skill like `/review`) | No* |
| `claude_args` | Pass-through args to Claude Code CLI | No |
| `anthropic_api_key` | Claude API key | Yes** |
| `github_token` | GitHub API access token | No |
| `trigger_phrase` | Trigger phrase (default: "@claude") | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

\*If prompt omitted, respond to trigger phrase in issue/PR comment
\*\*Required for direct Claude API; not needed when using Bedrock/Vertex

**Main CLI args** (`claude_args`):
```yaml
claude_args: "--max-turns 5 --model claude-sonnet-4-6 --mcp-config /path/to/config.json"
```
- `--max-turns`: Max conversation turns (default: 10)
- `--model`: Model to use
- `--mcp-config`: Path to MCP config file
- `--allowed-tools`: Comma-separated allowed tools
- `--debug`: Debug output

#### Usage examples (issue/PR comments)

```text
@claude implement this feature based on the issue description
@claude how should I implement user authentication for this endpoint?
@claude fix the TypeError in the user dashboard component
```

#### AWS Bedrock / Google Vertex AI

**AWS Bedrock workflow**:
```yaml
name: Claude PR Action
permissions:
  contents: write
  pull-requests: write
  issues: write
  id-token: write
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned]
jobs:
  claude-pr:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'issues' && contains(github.event.issue.body, '@claude'))
    runs-on: ubuntu-latest
    env:
      AWS_REGION: us-west-2
    steps:
      - uses: actions/checkout@v4
      - name: Generate GitHub App token
        id: app-token
        uses: actions/create-github-app-token@v2
        with:
          app-id: ${{ secrets.APP_ID }}
          private-key: ${{ secrets.APP_PRIVATE_KEY }}
      - name: Configure AWS Credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          aws-region: us-west-2
      - uses: anthropics/claude-code-action@v1
        with:
          github_token: ${{ steps.app-token.outputs.token }}
          use_bedrock: "true"
          claude_args: '--model us.anthropic.claude-sonnet-4-6 --max-turns 10'
```
> Bedrock model ID includes region prefix: `us.anthropic.claude-sonnet-4-6`

**Google Vertex AI**: Authenticate via GCP Workload Identity Federation. Set `use_vertex: "true"`, env vars `ANTHROPIC_VERTEX_PROJECT_ID`, `CLOUD_ML_REGION` required.

#### Cost considerations

| Cost item | Description |
|-----------|-------------|
| GitHub Actions minutes | Compute time on GitHub-hosted runner |
| API tokens | Token cost by prompt/response length |

**Optimization tips**:
- Use specific `@claude` commands to reduce unnecessary API calls
- Use `--max-turns` to avoid excessive iteration
- Workflow-level timeout to prevent runaway jobs
- GitHub concurrency control to limit parallel runs

#### Troubleshooting

| Issue | Check |
|-------|-------|
| No response to `@claude` | GitHub App installed, workflow enabled, API key secret set, use `@claude` not `/claude` |
| CI not running on Claude commits | Confirm GitHub App (not default Actions user), workflow trigger events |
| Auth error | API key validity/permissions, Bedrock/Vertex credentials |

---

### GitLab CI/CD

> Beta. Maintained by GitLab. See [GitLab issue](https://gitlab.com/gitlab-org/gitlab/-/issues/573776).

#### Key concepts

- `@claude` mention in issue/MR for implementation, MR creation, bug fixes
- Runs in isolated container sandbox
- Claude API, AWS Bedrock, Google Vertex AI all supported
- All changes reviewable via MR

#### How it works

1. **Event-driven**: `@claude` comment → gather context → build prompt → run Claude Code
2. **Provider abstraction**: Choose Claude API (SaaS) / AWS Bedrock / Google Vertex AI
3. **Sandbox execution**: Isolated container, network/filesystem limits, workspace-scoped permissions

#### Quick setup

1. Add `ANTHROPIC_API_KEY` in **Settings → CI/CD → Variables** (masked)
2. Add Claude job to `.gitlab-ci.yml`:

```yaml
stages:
  - ai

claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  variables:
    GIT_STRATEGY: fetch
  before_script:
    - apk update
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Summarize recent changes and suggest improvements'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

#### AWS Bedrock workflow (OIDC)

```yaml
claude-bedrock:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
  before_script:
    - apk add --no-cache bash curl jq git python3 py3-pip
    - pip install --no-cache-dir awscli
    - curl -fsSL https://claude.ai/install.sh | bash
    - export AWS_WEB_IDENTITY_TOKEN_FILE="${CI_JOB_JWT_FILE:-/tmp/oidc_token}"
    - if [ -n "${CI_JOB_JWT_V2}" ]; then printf "%s" "$CI_JOB_JWT_V2" > "$AWS_WEB_IDENTITY_TOKEN_FILE"; fi
    - >
      aws sts assume-role-with-web-identity
      --role-arn "$AWS_ROLE_TO_ASSUME"
      --role-session-name "gitlab-claude-$(date +%s)"
      --web-identity-token "file://$AWS_WEB_IDENTITY_TOKEN_FILE"
      --duration-seconds 3600 > /tmp/aws_creds.json
    - export AWS_ACCESS_KEY_ID="$(jq -r .Credentials.AccessKeyId /tmp/aws_creds.json)"
    - export AWS_SECRET_ACCESS_KEY="$(jq -r .Credentials.SecretAccessKey /tmp/aws_creds.json)"
    - export AWS_SESSION_TOKEN="$(jq -r .Credentials.SessionToken /tmp/aws_creds.json)"
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Implement the requested changes and open an MR'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
  variables:
    AWS_REGION: "us-west-2"
```

Required CI/CD Variables: `AWS_ROLE_TO_ASSUME`, `AWS_REGION`

#### Google Vertex AI workflow (WIF)

```yaml
claude-vertex:
  stage: ai
  image: gcr.io/google.com/cloudsdktool/google-cloud-cli:slim
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
  before_script:
    - apt-get update && apt-get install -y git && apt-get clean
    - curl -fsSL https://claude.ai/install.sh | bash
    - >
      gcloud auth login --cred-file=<(cat <<EOF
      {
        "type": "external_account",
        "audience": "${GCP_WORKLOAD_IDENTITY_PROVIDER}",
        "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
        "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${GCP_SERVICE_ACCOUNT}:generateAccessToken",
        "token_url": "https://sts.googleapis.com/v1/token"
      }
      EOF
      )
  script:
    - /bin/gitlab-mcp-server || true
    - >
      CLOUD_ML_REGION="${CLOUD_ML_REGION:-us-east5}"
      claude
      -p "${AI_FLOW_INPUT:-'Review and update code as requested'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
  variables:
    CLOUD_ML_REGION: "us-east5"
```

Required CI/CD Variables: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION`

#### Usage examples (issue/MR comments)

```text
@claude implement this feature based on the issue description
@claude suggest a concrete approach to cache the results of this API call
@claude fix the TypeError in the user dashboard component
```

#### Security & governance

- Each job runs in isolated container (network/filesystem limits)
- All changes reviewed via MR (reviewer sees diff)
- Branch protection and approval rules apply to AI-generated code
- Write scope limited by workspace permissions
- Use your own provider credentials for cost control

#### Troubleshooting

| Issue | Check |
|-------|-------|
| No response to `@claude` | Pipeline trigger, CI/CD Variables present, use `@claude` not `/claude` |
| Cannot post comments/MR | `CI_JOB_TOKEN` permissions or `api` scope PAT, `mcp__gitlab` tool enabled |
| Auth error | API key validity, OIDC/WIF setup, region/model availability |

---

### GitHub Actions vs GitLab CI/CD

| Aspect | GitHub Actions | GitLab CI/CD |
|--------|----------------|--------------|
| Status | GA (v1) | Beta |
| Maintainer | Anthropic | GitLab |
| Setup | `/install-github-app` or manual | Edit `.gitlab-ci.yml` |
| Trigger | `@claude` mention auto-detected | Webhook/pipeline trigger config |
| Action/Job | `anthropics/claude-code-action@v1` | Run `claude` CLI directly |
| Providers | Claude API, Bedrock, Vertex | Claude API, Bedrock, Vertex |
| Security | GitHub Secrets + App permissions | CI/CD Variables + container isolation |

---

## 14. Slack integration

> Docs: https://code.claude.com/docs/en/slack
> Slack Marketplace: https://slack.com/marketplace/A08SF47R6P4

### Key concepts

- `@Claude` mention → coding intent detected → Claude Code web session created
- Delegate coding work using Slack conversation context
- Built on Claude for Slack; routes coding requests to Claude Code web

### Prerequisites

| Requirement | Details |
|-------------|---------|
| Claude plan | Pro, Max, Teams, Enterprise (includes Claude Code access, premium seats) |
| Claude Code web | [claude.ai/code](https://claude.ai/code) access must be enabled |
| GitHub account | Linked in Claude Code web, at least one repo authorized |
| Slack auth | Slack account linked to Claude account |

### Setup

1. **Install Slack app**: Workspace admin installs from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. **Connect Claude**: Slack → Apps → Claude → App Home → click "Connect"
3. **Claude Code web**: Go to [claude.ai/code](https://claude.ai/code) → connect GitHub → authorize repos
4. **Routing mode**: Set in App Home
5. **Add to channel**: `/invite @Claude` in desired channel (not added automatically)

### Routing modes

| Mode | Behavior |
|------|----------|
| **Code only** | Route all `@Claude` mentions to Claude Code. Best for dev-only teams |
| **Code + Chat** | Analyze message; route coding to Claude Code, general Qs to Claude Chat |

> If misrouted in Code + Chat: use "Retry as Code" or choose Chat

### Flow

1. **Start**: Coding request via `@Claude` mention
2. **Detect**: Claude analyzes message → detects coding intent
3. **Session**: New Claude Code session at claude.ai/code
4. **Updates**: Post status to Slack thread
5. **Done**: Notify with @mention + summary + action buttons
6. **Review**: "View Session" for full history, "Create PR" for pull request

### Context collection

| Source | Behavior |
|--------|----------|
| **Thread** | Collect context from all messages in thread |
| **Channel** | Collect from recent channel messages |

> Note: `@Claude` has access to conversation context. Use only in trusted Slack channels.

### UI actions

| Action | Purpose |
|--------|---------|
| **View Session** | Open full Claude Code session in browser (history, continue, more requests) |
| **Create PR** | Create PR from session changes |
| **Retry as Code** | Retry in Code session if routed to Chat |
| **Change Repo** | Change repo Claude selected |

### Access

**Per user**:
| Access type | Description |
|-------------|-------------|
| Session | Runs under each user's Claude account |
| Usage / rate limit | Counts toward personal plan |
| Repo access | Only repos user has connected |
| Session history | Shown in claude.ai/code history |

**Workspace**:
- Workspace admin controls install/removal of Claude app
- Enterprise Grid: org admin controls per-workspace access
- Removing app revokes access for all users in that workspace

**Channel-based**:
- Claude responds only in channels where invited (`/invite @Claude`)
- Public and private channels supported
- Admin can limit Claude Code use via channel access

### Use cases

| Case | Description |
|------|-------------|
| Bug investigation/fix | Investigate and fix bugs reported in Slack |
| Code review/edits | Small features, refactors based on team feedback |
| Collaborative debugging | Use team discussion (repro, user reports) as context |
| Parallel work | Start coding from Slack → do other work → get notified when done |

### Slack vs using web directly

| Use Slack when | Use web when |
|-----------------|--------------|
| Context is already in Slack | You need to upload files |
| Starting work asynchronously | You need real-time interaction while developing |
| Team visibility matters | Long or complex tasks |

### Writing effective requests

- **Be specific**: Include file names, function names, error messages
- **Provide context**: Specify repo/project if unclear from conversation
- **Define success**: Tests? Docs? PR?
- **Use threads**: Discuss bug/feature in thread → Claude gets full context

### Current limitations

- **GitHub only**: Only GitHub repos supported
- **One PR**: One PR per session
- **Rate limit**: Personal Claude plan limits apply
- **Web access required**: Without Claude Code web access you only get Claude Chat
- **No DMs**: Works in channels only (public or private)

### Troubleshooting

| Issue | Fix |
|-------|-----|
| Session not starting | Check Claude account connection in App Home → web access → GitHub repo connection |
| Repo not visible | Connect repo at claude.ai/code → check GitHub permissions → reconnect GitHub |
| Wrong repo selected | "Change Repo" button → include repo name in request |
| Auth error | Disconnect/reconnect in App Home → correct Claude account → plan includes Claude Code access |

---

# Appendix

---

## Appendix A: Feature selection guide (when to use what?)

| Need | Use | Why |
|------|-----|-----|
| "Rules that always apply" | **CLAUDE.md** | Loaded every session, "Always do X" |
| "Reference/workflow when needed" | **Skills** | On-demand load, `/<name>` invocation |
| "Connect external systems" | **MCP** | Jira, Slack, DB, etc. |
| "Parallel isolated work" | **Subagents** | Own context, avoid polluting main |
| "Deterministic automation (no LLM)" | **Hooks** | Event-based, deterministic |
| "Complex work needing discussion/collab" | **Agent Teams** | Teammates talk directly, self-coordinate |
| "Reuse/share/ship" | **Plugins** | Packaging, versioning |
| "Non-interactive in CI/CD" | **Headless (`-p`)** | Programmatic execution |

### Decision tree

```
Want to add instructions
├── Always apply? → CLAUDE.md
├── Only for certain paths? → .claude/rules/*.md
├── Only when needed? → Skills
└── Share across projects? → Plugins

Want to automate
├── Deterministic, no LLM? → Hooks
├── Connect external systems? → MCP
├── Isolated exploration/work? → Subagents
└── Team collaboration? → Agent Teams

Run in CI/CD
└── Headless (-p) + --allowedTools
```

---

## Appendix B: Context optimization

### Load timing/cost by feature

| Feature | When loaded | Context cost |
|---------|-------------|---------------|
| CLAUDE.md | Every session start | Full content (keep under 500 lines!) |
| Auto Memory (MEMORY.md) | Every session start | First 200 lines only |
| Skills (description) | Every session start | 2% of context (fallback 16K chars) |
| Skills (full content) | On invocation | Per invoked skill |
| Subagents | On delegation | Main gets result only (isolated) |
| Rules (`.claude/rules/`) | When working on matching path | Per matched rules |
| Hooks | On event | None (external execution) |
| MCP tool list | Session start | Optimizable via Tool Search |

### Principles

1. **Keep CLAUDE.md under 500 lines** — Move reference material to Skills
2. **`/clear` between unrelated tasks** — Avoid context pollution
3. **Isolate heavy output in Subagent** — Protect main context
4. **Use path-conditional Rules** — Avoid loading unnecessary rules
5. **Use `/compact <instructions>`** — Mid-session cleanup
6. **Enable MCP Tool Search** — When you have 10+ tools

---

## Appendix C: Feature comparison matrix

### Skills vs Subagents

| Aspect | Skills | Subagents |
|--------|--------|-----------|
| Identity | Reusable instructions/knowledge/workflow | Isolated worker (own context) |
| Main benefit | Share content across context | Context isolation |
| Best for | Reference, invokable workflows | Lots of file reads, parallel work |

### CLAUDE.md vs Skills

| Aspect | CLAUDE.md | Skills |
|--------|-----------|--------|
| Load | Every session, automatic | On-demand |
| Workflow trigger | No | `/<name>` |
| Best for | "Always do X" rules | Reference, invokable workflows |

**Rule of thumb**: Keep CLAUDE.md under ~500 lines. Beyond that, split into Skills.

### Subagents vs Agent Teams

| Aspect | Subagents | Agent Teams |
|--------|-----------|-------------|
| Communication | Report to main only | Teammates message each other |
| Coordination | Main manages | Shared task list |
| Cost | Lower | Higher |
| Best for | Focused work where only result matters | Complex work needing discussion/collab |

### MCP vs Skills

| Aspect | MCP | Skills |
|--------|-----|--------|
| Purpose | Connect external services (API) | Internal instructions/workflows |
| Execution | Tool calls (external server) | Prompt injection |
| Examples | Jira issue read, DB query | Code review checklist, deploy guide |

### Hooks vs Skills

| Aspect | Hooks | Skills |
|--------|-------|--------|
| Execution | Deterministic (no LLM) | LLM decides/runs |
| Trigger | Event-based (automatic) | `/command` or Claude auto-invocation |
| Best for | Formatting, protection, notifications, logging | Workflows, reference, analysis |

### Feature comparison summary

| Feature | What it does | When to use | Example |
|---------|---------------|-------------|---------|
| CLAUDE.md | Persistent context | "Always do X" rules | "Use pnpm, not npm" |
| Skill | Instructions/knowledge/workflow | Reuse content, repeat tasks | `/review` for code review checklist |
| Subagent | Isolated execution context | Context isolation, parallel work | Research that reads many files |
| Agent Teams | Coordinate multiple sessions | Parallel research, competing hypotheses | Security/perf/test review in parallel |
| MCP | Connect external services | External data/actions | DB query, Slack post |
| Hook | Event-based script | Predictable automation | Run ESLint after edit |

---

## Hands-on: GitHub Actions + CLAUDE_CODE_OAUTH_TOKEN (2026-02-28)

### Background

Setup uses `CLAUDE_CODE_OAUTH_TOKEN` (Claude.ai account OAuth) for auth instead of `ANTHROPIC_API_KEY`.

### Final working workflow

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned]

jobs:
  claude:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'issues' && contains(github.event.issue.body, '@claude'))
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write   # ← Required when using CLAUDE_CODE_OAUTH_TOKEN
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          claude_args: "--max-turns 10"
```

### Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Unable to get ACTIONS_ID_TOKEN_REQUEST_URL` | Missing `id-token: write` permission | Add `id-token: write` to permissions |
| `Bad credentials` | OAuth token not set or empty | Verify `CLAUDE_CODE_OAUTH_TOKEN` in GitHub Secrets |
| `issue_comment` runs old workflow | Workflow triggered from main branch | Push changes to main before testing |

### Auth comparison

| Method | Secret name | Extra permission | Notes |
|--------|-------------|-----------------|-------|
| API key | `ANTHROPIC_API_KEY` | None | Direct API use |
| OAuth token | `CLAUDE_CODE_OAUTH_TOKEN` | `id-token: write` required | Claude.ai account link |

### Takeaways

- `issue_comment` uses the workflow on **main** → push changes to main first to test
- `CLAUDE_CODE_OAUTH_TOKEN` needs OIDC token → `id-token: write` is required
- Deny rule in `.claude/settings.json` (`git push *`) blocks Claude from pushing → intended safeguard
