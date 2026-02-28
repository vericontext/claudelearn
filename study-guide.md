# Claude Code Study Guide

> `note-reference.md` — public reference (do not modify)
> `note.md` — working copy (personal notes, checkboxes, freely editable)

---

## Learning Principles

1. **Reading alone is not enough** — always configure and run things yourself
2. **One at a time** — fully internalize one feature before moving on
3. **Apply to real projects** — use it on your current work, not practice exercises

---

## Phase 1: Basic Setup (Day 1~2)

> Goal: Configure Claude Code to fit your workflow

### 1-1. Memory / CLAUDE.md

**Read**: note.md section 1

**Practice**:
- [x] Write `CLAUDE.md` for the current project (start with 5 lines or fewer)
- [x] Write `~/.claude/CLAUDE.md` for global personal settings
- [x] Run `/init` and review the auto-generated result
- [x] Create one path-specific rule in `.claude/rules/`
- [x] Run `/memory` and check Auto Memory status

**Checkpoint**: Verify Claude follows your rules when a new session starts

### 1-2. Permissions

**Read**: note.md section 2

**Practice**:
- [x] Check current permission mode (is it `default`?)
- [x] Add allow rules for frequently used commands in `.claude/settings.json`
- [x] Add one deny rule (e.g. `Bash(rm -rf *)`)
- [ ] Switch to `acceptEdits` mode and feel the difference

**Checkpoint**: Confirm allow/deny rules behave as intended

### 1-3. Best Practices

**Read**: note.md section 3

**Practice**:
- [x] Apply the "Explore → Plan → Implement → Commit" 4-step flow consciously in your next task
- [x] Make `/clear` a habit — run it every time you switch tasks
- [x] Read the bad vs good prompt comparison table and apply it to your next prompt

**Checkpoint**: Complete a task in one session without context pollution

---

## Phase 2: Core Extensions (Day 3~7)

> Goal: Master the 3 most frequently used features

### 2-1. Skills

**Read**: note.md section 4

**Practice**:
- [x] Create a simple skill: `.claude/skills/hello/SKILL.md`
  ```yaml
  ---
  name: hello
  description: A greeting skill
  ---
  Greet the user warmly in Korean.
  ```
- [x] Run `/hello` and verify it works
- [x] Build real-world skills — see note.md practical examples:
  - `/ship`: read staged/unstaged diff, auto-commit + create PR
  - `/review [pr-number]`: analyze PR diff/comments and post review
- [x] Try `!`command`` dynamic context injection
- [x] Try `$ARGUMENTS` argument passing
- [ ] Compare `disable-model-invocation: true` vs default behavior

**Checkpoint**: Complete an actual commit + PR creation with `/ship` in one command

### 2-2. Hooks

**Read**: note.md section 6

**Practice**:
- [x] Auto-run tests on file edits (`PostToolUse` + `Edit|Write` matcher)
  - Test results are automatically injected into context every time Claude edits a file
- [ ] Auto-validate on task completion (`Stop` + `type: agent`)
  - Run tests after every response; feed failures back to Claude
- [ ] Set up auto-format hook (prettier/eslint integration)
- [x] Create a hook that blocks edits with exit code 2 (protected files)
- [x] Add a compact reminder hook (`SessionStart` + `compact` matcher)

**Checkpoint**: File edit → test auto-run → Claude auto-fixes on failure

### 2-3. MCP

**Read**: note.md section 7

**Practice**:
- [x] Run `/mcp` and check current status
- [x] Add one HTTP MCP server (GitHub, Notion, or a service you already use)
  ```bash
  claude mcp add --transport http github https://api.githubcopilot.com/mcp/
  ```
- [x] Verify with `claude mcp list`
- [ ] Reference an issue directly using `@github:issue://number` and request implementation
- [x] Set up project-shared config with `.mcp.json`

**Checkpoint**: Use `@service:resource://ID` syntax to access external data in conversation

---

## Phase 3: Advanced Features (Day 8~14)

> Goal: Master patterns for handling complex tasks efficiently

### 3-1. Subagents

**Read**: note.md section 5

**Practice**:
- [x] Create one custom agent: `.claude/agents/reviewer.md`
- [ ] Experiment with `tools`, `model`, `maxTurns` frontmatter settings
- [x] Build 3 parallel review agents — see note.md practical examples:
  - `security-reviewer` (opus) — OWASP Top 10 security analysis
  - `perf-reviewer` (sonnet) — N+1 query / memory leak detection
  - `test-validator` (haiku) — test coverage verification
- [ ] Experience the difference between foreground and background execution
- [ ] Set `memory: user` and verify cross-session learning

**Checkpoint**: Run all 3 agents in parallel with one sentence: "Review security/performance/tests simultaneously"

### 3-2. Headless / Agent SDK

**Read**: note.md section 10

**Practice**:
- [ ] Run `claude -p "simple task" --output-format json`
- [ ] Run with `--allowedTools` for auto-approved execution
- [ ] Unix pipe pattern: `cat error.txt | claude -p "analyze the cause"`
- [ ] Resume a session with `--continue` / `--resume`
- [ ] Integrate Claude into a simple shell script

**Checkpoint**: Build one automated pipeline running non-interactively

### 3-3. Plugins (Optional)

**Read**: note.md section 8

**Practice**:
- [ ] Package the skills/agents/hooks you've built into a plugin
- [ ] Test with `claude --plugin-dir ./my-plugin`
- [ ] Write the `plugin.json` manifest

**Checkpoint**: Load the plugin in a different project and verify it works

---

## Phase 4: Team / Automation (Day 15+)

> Goal: Integrate Claude Code into team workflows

### 4-1. CI/CD

**Read**: note.md section 13

**Practice**:
- [ ] GitHub Actions: run `/install-github-app`
- [x] Deploy the base workflow `.github/workflows/claude.yml`
- [ ] Test `@claude` mention in a PR
- [x] Set up automated review with a custom prompt

### 4-2. Slack Integration

**Read**: note.md section 14

**Practice**:
- [ ] Install Claude App + connect account
- [ ] Choose routing mode (Code only vs Code + Chat)
- [ ] Test a coding task request with `@Claude` in a channel

### 4-3. Agent Teams (Experimental)

**Read**: note.md section 9

**Practice**:
- [ ] Enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- [ ] Try a simple parallel task (e.g. security review + performance review)

---

## Study Tips

### Priority Matrix

```
          High frequency
            |
  Phase 1   |   Phase 2
  (basics)  |   (core)
            |
───────────┼───────────
            |
  Phase 4   |   Phase 3
  (team/CI) |   (advanced)
            |
          Low frequency
```

- **Phase 1+2 covers 80% of daily usage** — focus here
- Phase 3 as needed for complex tasks
- Phase 4 when onboarding a team

### Repeating Learning Cycle

```
Week 1: Phase 1 + 2-1 (Skills)
Week 2: Phase 2-2, 2-3 (Hooks, MCP) + Phase 1 review
Week 3: Phase 3 as needed + Phase 2 review
Week 4+: Phase 4 + overall workflow optimization
```

### How to Keep Notes

After completing each Phase, add personal notes to `note.md`:
- What turned out to be useful
- What was different from expectations
- Settings you customized for your project

---

## File Structure

```
claudelearn/
├── note-reference.md   # public reference (do not touch)
├── note.md             # working copy (notes, checks, edits welcome)
└── study-guide.md      # this file (study guide)
```
