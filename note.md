# Claude Code 기능 딥다이브 노트

> 공식 문서: https://code.claude.com/docs/en/overview
> 목차 전체: https://code.claude.com/docs/llms.txt

---

## 학습 현황

| 기능 | 상태 | Part | 문서 링크 |
|------|------|------|-----------|
| Memory / CLAUDE.md | ✅ 완료 | 1 | [memory](https://code.claude.com/docs/en/memory) |
| Permissions | ✅ 완료 | 1 | [permissions](https://code.claude.com/docs/en/permissions) |
| Best Practices | ✅ 완료 | 1 | [best-practices](https://code.claude.com/docs/en/best-practices) |
| Skills (슬래시 커맨드) | ✅ 완료 | 2 | [skills](https://code.claude.com/docs/en/skills) |
| Subagents | ✅ 완료 | 2 | [sub-agents](https://code.claude.com/docs/en/sub-agents) |
| Hooks | ✅ 완료 | 2 | [hooks](https://code.claude.com/docs/en/hooks) |
| MCP | ✅ 완료 | 2 | [mcp](https://code.claude.com/docs/en/mcp) |
| Plugins | ✅ 완료 | 2 | [plugins](https://code.claude.com/docs/en/plugins) |
| Agent Teams | ✅ 완료 | 3 | [agent-teams](https://code.claude.com/docs/en/agent-teams) |
| Headless / Agent SDK | ✅ 완료 | 3 | [headless](https://code.claude.com/docs/en/headless) |
| Common Workflows | ✅ 완료 | 3 | [common-workflows](https://code.claude.com/docs/en/common-workflows) |
| 플랫폼 & 통합 | ✅ 완료 | 4 | [overview](https://code.claude.com/docs/en/overview) |
| CI/CD | ✅ 완료 | 4 | [github-actions](https://code.claude.com/docs/en/github-actions) |
| Slack 통합 | ✅ 완료 | 4 | [slack](https://code.claude.com/docs/en/slack) |

---

# Part 1: 기본 세팅 (먼저 알아야 할 것들)

---

## 1. Memory / CLAUDE.md

> 문서: https://code.claude.com/docs/en/memory

### 핵심 개념

Claude Code에는 두 종류의 영속 메모리가 있다:
- **CLAUDE.md 파일**: 직접 작성/관리하는 지시사항, 규칙, 선호 설정
- **Auto Memory**: Claude가 프로젝트 패턴, 주요 명령어, 선호를 자동 저장

### 메모리 위계 구조 (6단계)

| 메모리 타입 | 위치 | 용도 | 공유 범위 |
|------------|------|------|-----------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux: `/etc/claude-code/CLAUDE.md` | 조직 전체 코딩 표준, 보안 정책 | 조직 전체 |
| **Project** | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` | 프로젝트 아키텍처, 코딩 규칙 | 팀원 (소스 관리) |
| **Project rules** | `./.claude/rules/*.md` | 모듈별/경로별 세부 규칙 | 팀원 (소스 관리) |
| **User** | `~/.claude/CLAUDE.md` | 개인 코드 스타일 선호 | 본인만 (전체 프로젝트) |
| **Project local** | `./CLAUDE.local.md` | 개인 프로젝트별 설정 (샌드박스 URL 등) | 본인만 (현재 프로젝트) |
| **Auto memory** | `~/.claude/projects/<project>/memory/` | Claude 자동 메모, 학습 내용 | 본인만 (프로젝트별) |

### Auto Memory 구조

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # 간결한 인덱스 — 매 세션 시작 시 로드 (첫 200줄)
  debugging.md       # 상세 디버깅 패턴 (필요 시 읽기)
  api-conventions.md # API 설계 결정 (필요 시 읽기)
```

- `MEMORY.md` 첫 200줄이 시스템 프롬프트에 주입됨
- 토픽 파일은 시작 시 로드되지 않고 Claude가 필요 시 읽음
- `/memory` 명령어로 토글
- 비활성화:
```json
// ~/.claude/settings.json
{ "autoMemoryEnabled": false }
```
```bash
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1  # 강제 비활성화
```

### CLAUDE.md Import (`@` 문법)

```markdown
See @README for project overview and @package.json for available npm commands.
# 추가 지침
- git workflow @docs/git-instructions.md
```
- 상대/절대 경로 모두 가능
- 최대 5단계 재귀 import
- 코드 블록/인라인 코드 내에서는 평가 안 됨

### 모듈형 Rules (`.claude/rules/`)

```
your-project/
  .claude/
    CLAUDE.md
    rules/
      code-style.md
      testing.md
      security.md
```

경로 조건부 규칙 (YAML frontmatter):
```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API 개발 규칙
- 모든 API 엔드포인트에 입력 검증 필수
```

지원 패턴:
| 패턴 | 매칭 |
|------|------|
| `**/*.ts` | 모든 하위 디렉토리의 TypeScript 파일 |
| `src/**/*` | src/ 아래 모든 파일 |
| `*.md` | 프로젝트 루트의 마크다운 파일 |
| `src/components/*.tsx` | 특정 디렉토리의 React 컴포넌트 |

중괄호 확장: `src/**/*.{ts,tsx}`

사용자 수준 rules: `~/.claude/rules/` — 모든 프로젝트에 적용 (프로젝트 rules보다 먼저 로드)

### 주요 명령어

| 명령어 | 기능 |
|--------|------|
| `/init` | 코드베이스 분석 → 빌드 시스템, 테스트 프레임워크, 코드 패턴 감지 |
| `/memory` | Auto Memory 토글 |

### 추가 디렉토리에서 CLAUDE.md 로드

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

---

## 2. Permissions

> 문서: https://code.claude.com/docs/en/permissions

### 도구 타입별 기본 승인

| 도구 타입 | 예시 | 승인 필요 | "다시 묻지 않기" 동작 |
|-----------|------|-----------|----------------------|
| 읽기 전용 | File reads, Grep | 아니오 | N/A |
| Bash 명령 | 셸 실행 | 예 | 프로젝트 디렉토리+명령어별 영구 저장 |
| 파일 수정 | Edit/Write | 예 | 세션 종료까지 |

### 5가지 권한 모드

| 모드 | 설명 |
|------|------|
| `default` | 표준: 첫 사용 시 승인 요청 |
| `acceptEdits` | 파일 편집 자동 승인 (세션 동안) |
| `plan` | Plan Mode: 분석만 가능, 수정 불가 |
| `dontAsk` | `/permissions`에서 사전 승인된 것만 허용, 나머지 자동 거부 |
| `bypassPermissions` | 모든 승인 건너뜀 (안전한 환경 필수) |

### 권한 규칙 문법

**도구 전체 매칭**:
```json
{ "allow": ["Bash", "WebFetch", "Read"] }
```

**세밀한 지정**:
| 규칙 | 효과 |
|------|------|
| `Bash(npm run build)` | 정확한 명령 매칭 |
| `Read(./.env)` | .env 파일 읽기 매칭 |
| `WebFetch(domain:example.com)` | 특정 도메인 요청 매칭 |

**와일드카드 패턴**:
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

### 경로 패턴 문법

| 패턴 | 의미 | 예시 | 매칭 |
|------|------|------|------|
| `//path` | 파일시스템 절대 경로 | `Read(//Users/alice/secrets/**)` | `/Users/alice/secrets/**` |
| `~/path` | 홈 디렉토리 기준 | `Read(~/Documents/*.pdf)` | `/Users/alice/Documents/*.pdf` |
| `/path` | 프로젝트 루트 기준 | `Edit(/src/**/*.ts)` | `<project root>/src/**/*.ts` |
| `path` 또는 `./path` | 현재 디렉토리 기준 | `Read(*.env)` | `<cwd>/*.env` |

### MCP / Task 권한

```json
{
  "permissions": {
    "allow": ["mcp__puppeteer"],
    "deny": ["mcp__puppeteer__puppeteer_navigate", "Task(Explore)"]
  }
}
```
- `mcp__puppeteer`: puppeteer 서버의 모든 도구 매칭
- `mcp__puppeteer__puppeteer_navigate`: 특정 도구만 매칭
- `Task(Explore)`: 특정 서브에이전트 차단

### 관리자 설정 (Managed Settings)

| 설정 | 설명 |
|------|------|
| `disableBypassPermissionsMode` | `"disable"`로 bypassPermissions 모드 차단 |
| `allowManagedPermissionRulesOnly` | 사용자/프로젝트 권한 규칙 정의 차단 |
| `allowManagedHooksOnly` | 사용자/프로젝트/플러그인 훅 로딩 차단 |
| `allowManagedMcpServersOnly` | 관리 설정의 MCP 서버만 허용 |
| `allow_remote_sessions` | Remote Control 및 웹 세션 접근 제어 |

### 실전 설정 예제

**개발자 친화 (빠른 반복)**:
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

**보안 강화 (프로덕션)**:
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

> 문서: https://code.claude.com/docs/en/best-practices

### 핵심 원리

> 컨텍스트 창은 빠르게 채워지고, 채워질수록 성능이 저하된다. 가장 중요한 리소스.

### 효과적 사용 5원칙

#### 원칙 1: 검증 기준 제공

| 전략 | Before | After |
|------|--------|-------|
| 검증 기준 제공 | "이메일 검증 함수 구현해줘" | "validateEmail 함수 작성. user@example.com→true, invalid→false. 구현 후 테스트 실행" |
| UI 변경 시각 검증 | "대시보드 더 보기 좋게" | "[스크린샷 첨부] 이 디자인 구현. 스크린샷 찍어서 비교" |
| 근본 원인 해결 | "빌드 실패함" | "빌드가 이 에러로 실패: [에러 붙여넣기]. 고치고 빌드 성공 확인" |

#### 원칙 2: 탐색 → 계획 → 구현 → 커밋 (4단계)

1. **탐색** (Plan Mode) — 파일 읽기, 질문 답변, 변경 없음
2. **계획** (Plan Mode) — 상세 구현 계획 수립
3. **구현** (Normal Mode) — 코드 작성, 계획 대비 검증
4. **커밋** (Normal Mode) — 서술적 메시지로 커밋, PR 생성

#### 원칙 3: 효과적인 CLAUDE.md 작성

| 포함할 것 | 제외할 것 |
|-----------|-----------|
| Claude가 추측 못 할 Bash 명령 | 코드 읽으면 알 수 있는 것 |
| 기본값과 다른 코드 스타일 규칙 | Claude가 이미 아는 표준 규약 |
| 테스트 지침 | 상세 API 문서 (링크로 대체) |
| 저장소 에티켓 (브랜치 명명, PR 규약) | 자주 바뀌는 정보 |
| 프로젝트 고유 아키텍처 결정 | 긴 설명이나 튜토리얼 |
| 개발 환경 quirks | 파일별 코드베이스 설명 |
| 흔한 함정 | "깔끔한 코드 작성" 같은 자명한 것 |

예시:
```markdown
# Code style
- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible

# Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, not the whole test suite, for performance
```

#### 원칙 4: 컨텍스트 적극 관리

| 명령어 | 용도 |
|--------|------|
| `/clear` | 관련 없는 작업 사이에 컨텍스트 비우기 |
| `/compact <지시>` | 제어된 압축 (지시사항 포함 가능) |
| `Esc + Esc` 또는 `/rewind` | 체크포인트에서 되감기 |
| CLAUDE.md 커스텀 | 압축 동작 커스터마이즈 |

#### 원칙 5: Claude에게 인터뷰 시키기

```text
I want to build [간단한 설명]. Interview me in detail using the AskUserQuestion tool.
Ask about technical implementation, UI/UX, edge cases, concerns, and tradeoffs.
Keep interviewing until we've covered everything, then write a complete spec to SPEC.md.
```

### 좋은 프롬프트 vs 나쁜 프롬프트

| 나쁜 프롬프트 | 좋은 프롬프트 |
|--------------|--------------|
| "이메일 검증 함수 구현" | "validateEmail 작성. test cases 포함, 구현 후 테스트 실행" |
| "대시보드 개선" | "[스크린샷] 이 디자인 구현, 스크린샷으로 비교" |
| "빌드 실패함" | "이 에러로 실패: [에러]. 고치고 빌드 성공 확인" |
| "코드 리팩토링해줘" | "utils.js를 ES2024로 리팩토링, 동일 동작 유지, 테스트 실행" |

### 흔한 실패 패턴

| 패턴 | 해결법 |
|------|--------|
| Kitchen sink 세션 (한 세션에 다 우겨넣기) | 관련 없는 작업 사이에 `/clear` |
| 계속 수정 지시 (2회 이상) | `/clear` 하고 더 나은 프롬프트로 재시작 |
| 과도한 CLAUDE.md | 무자비하게 가지치기 |
| 검증 없는 신뢰 | 항상 검증 기준 제공 |
| 무한 탐색 | 범위 제한하거나 서브에이전트 사용 |

### 병렬 세션 활용 (Writer/Reviewer 패턴)

| Session A (Writer) | Session B (Reviewer) |
|---|---|
| `Implement a rate limiter for our API endpoints` | |
| | `Review the rate limiter implementation in @src/middleware/rateLimiter.ts` |
| `Here's the review feedback: [B 결과]. Address these issues.` | |

### Fan Out (대량 작업)

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

---

# Part 2: 확장 기능 (하나씩 익히기)

---

## 4. Skills (슬래시 커맨드)

> 문서: https://code.claude.com/docs/en/skills

### 핵심 개념
- `SKILL.md` 파일로 정의하는 커스텀 커맨드
- 기존 `.claude/commands/` 방식을 대체 (하위 호환은 유지)
- [Agent Skills](https://agentskills.io) 오픈 표준 기반

### 저장 위치 (우선순위 순)
| 위치 | 경로 | 적용 범위 |
|------|------|-----------|
| Enterprise | managed settings | 조직 전체 |
| Personal | `~/.claude/skills/<name>/SKILL.md` | 내 모든 프로젝트 |
| Project | `.claude/skills/<name>/SKILL.md` | 해당 프로젝트만 |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | 플러그인 활성화된 곳 |

### SKILL.md 구조
```yaml
---
name: skill-name
description: 언제 이 스킬을 쓸지 설명 (Claude가 자동 호출 판단에 사용)
disable-model-invocation: true  # Claude 자동 호출 방지 (수동만 가능)
user-invocable: false           # /메뉴에서 숨김 (Claude만 호출 가능)
allowed-tools: Read, Grep, Glob # 이 스킬 실행 시 허용 도구
context: fork                   # 서브에이전트에서 격리 실행
agent: Explore                  # fork 시 사용할 에이전트 타입
model: sonnet                   # 이 스킬 실행 시 사용할 모델
---

스킬 지시사항 (마크다운)...
```

### 프론트매터 필드 전체

| 필드 | 필수 | 설명 |
|------|------|------|
| `name` | 아니오 | 슬래시 커맨드명. 소문자/숫자/하이픈 (최대 64자). 디렉토리명이 기본값 |
| `description` | 권장 | Claude가 자동 호출 여부 판단에 사용 → **잘 써야 함** |
| `argument-hint` | 아니오 | 자동완성 시 힌트. 예: `[issue-number]` |
| `disable-model-invocation` | 아니오 | `true`면 Claude 자동 실행 불가. 기본: `false` |
| `user-invocable` | 아니오 | `false`면 `/` 메뉴에서 숨김. 기본: `true` |
| `allowed-tools` | 아니오 | 스킬 활성 시 승인 없이 쓸 수 있는 도구 |
| `model` | 아니오 | 스킬 실행 시 사용할 모델 |
| `context` | 아니오 | `fork`로 설정하면 서브에이전트에서 실행 |
| `agent` | 아니오 | `context: fork` 시 사용할 에이전트 타입 |
| `hooks` | 아니오 | 이 스킬 라이프사이클에 한정된 훅 |

### 인수 전달
```yaml
# $ARGUMENTS - 전체 인수
# $ARGUMENTS[N] 또는 $N - 특정 인수 (0-based)
# ${CLAUDE_SESSION_ID} - 현재 세션 ID

Fix GitHub issue $ARGUMENTS following our coding standards.
Migrate the $0 component from $1 to $2.
```

### 동적 컨텍스트 주입 (`!`command``)
```yaml
## PR 정보
- diff: !`gh pr diff`
- 댓글: !`gh pr view --comments`
- 변경 파일: !`gh pr diff --name-only`
```
스킬 실행 전에 셸 명령을 실행하고 결과를 프롬프트에 삽입.

### 지원 파일 구조
```
my-skill/
├── SKILL.md        # 필수
├── template.md     # 선택
├── examples/
└── scripts/
    └── validate.sh
```

### 호출 제어 매트릭스
| 설정 | 사용자 호출 | Claude 호출 | 컨텍스트 로드 |
|------|------------|------------|--------------|
| 기본 | O | O | 설명만 항상 로드 |
| `disable-model-invocation: true` | O | X | 로드 안 됨 |
| `user-invocable: false` | X | O | 설명만 항상 로드 |

### 서브에이전트에서 실행

| 방식 | 시스템 프롬프트 | 태스크 | 추가 로드 |
|------|---------------|--------|-----------|
| Skill + `context: fork` | 에이전트 타입에서 | SKILL.md 내용 | CLAUDE.md |
| Subagent + `skills` 필드 | 서브에이전트 본문 | Claude 위임 메시지 | 프리로드 스킬 + CLAUDE.md |

### 스킬 예산

설명문은 컨텍스트 창의 2%까지 로드 (폴백: 16,000자). 오버라이드:
```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=32000
```

### 실전 예제

#### `/ship` — 커밋 + PR 한 커맨드로

```yaml
---
name: ship
description: 현재 변경사항을 커밋하고 PR을 생성. 작업 완료 시 사용.
---
## 현재 변경사항
!`git diff --staged`
!`git diff`

위 변경사항을 분석하여:
1. 변경 내용을 요약한 커밋 메시지 작성 (영어, 50자 이내)
2. git add -A && git commit 실행
3. 한국어로 PR 제목/본문 작성
4. gh pr create 실행
```

#### `/review` — PR diff 읽고 리뷰 댓글 작성

```yaml
---
name: review
description: PR 코드 리뷰. /review 123 형식으로 PR 번호 전달.
argument-hint: "[pr-number]"
---
## PR #$ARGUMENTS 리뷰 요청

변경 파일:
!`gh pr diff $ARGUMENTS --name-only`

전체 diff:
!`gh pr diff $ARGUMENTS`

기존 댓글:
!`gh pr view $ARGUMENTS --comments`

위 내용을 바탕으로 버그/보안/성능/개선점을 분석하여 PR에 코멘트 달아주세요.
```

---

## 5. Subagents

> 문서: https://code.claude.com/docs/en/sub-agents

### 핵심 개념
- 독립적인 컨텍스트 창을 가진 전문화 에이전트
- 메인 대화의 컨텍스트 오염 방지
- 특정 도구/권한만 부여해 제약된 환경에서 실행

### 내장 에이전트
| 에이전트 | 모델 | 도구 | 용도 |
|---------|------|------|------|
| Explore | Haiku (빠름) | 읽기 전용 | 파일 탐색, 코드 검색 |
| Plan | 상속 | 읽기 전용 | Plan mode 리서치 |
| general-purpose | 상속 | 전체 | 복잡한 다단계 작업 |
| Bash | 상속 | 터미널 명령 | 별도 컨텍스트 |
| statusline-setup | Sonnet | `/statusline` 설정 | 상태줄 설정 |
| Claude Code Guide | Haiku | 기능 Q&A | Claude Code 질문 |

### 생성 방법
- `/agents` — 인터랙티브 UI로 생성/관리
- `claude agents` — CLI에서 목록 확인
- 파일 직접 생성: `.claude/agents/<name>.md`
- `--agents` 플래그로 세션 한정 정의

### 에이전트 파일 구조
```markdown
---
name: code-reviewer
description: 코드 리뷰 전문가. 코드 수정 후 즉시 호출.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
maxTurns: 50
memory: user
background: false
isolation: worktree
---

시스템 프롬프트 (마크다운)...
```

### 스코프 우선순위

| 위치 | 스코프 | 우선순위 |
|------|--------|---------|
| `--agents` CLI 플래그 | 현재 세션 | 1 (최고) |
| `.claude/agents/` | 현재 프로젝트 | 2 |
| `~/.claude/agents/` | 모든 프로젝트 | 3 |
| Plugin `agents/` | 플러그인 활성화된 곳 | 4 (최저) |

### CLI 정의 서브에이전트

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

### 프론트매터 필드 전체

| 필드 | 필수 | 설명 |
|------|------|------|
| `name` | 예 | 고유 식별자 |
| `description` | 예 | Claude가 위임 시점 판단에 사용 |
| `tools` | 아니오 | 도구 allowlist (생략 시 전체 상속) |
| `disallowedTools` | 아니오 | 제외할 도구 denylist |
| `model` | 아니오 | `sonnet`, `opus`, `haiku`, `inherit` |
| `permissionMode` | 아니오 | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | 아니오 | 최대 실행 턴 수 |
| `skills` | 아니오 | 시작 시 주입할 스킬 목록 |
| `mcpServers` | 아니오 | 사용 가능한 MCP 서버 |
| `hooks` | 아니오 | 라이프사이클 훅 |
| `memory` | 아니오 | `user`, `project`, `local` |
| `background` | 아니오 | `true`면 항상 백그라운드 실행 |
| `isolation` | 아니오 | `worktree`로 git worktree 격리 |

### Skills 프리로드
```yaml
skills:
  - api-conventions
  - error-handling-patterns
```
에이전트 시작 시 스킬 전체 내용이 컨텍스트에 주입됨.

### Persistent Memory
```yaml
memory: user  # ~/.claude/agent-memory/<name>/
```

| 스코프 | 위치 | 사용 시점 |
|--------|------|-----------|
| `user` | `~/.claude/agent-memory/<name>/` | 모든 프로젝트 공유 학습 |
| `project` | `.claude/agent-memory/<name>/` | 프로젝트 한정, 공유 가능 |
| `local` | `.claude/agent-memory-local/<name>/` | 프로젝트 한정, VCS 제외 |

### 포그라운드 vs 백그라운드
- **포그라운드**: 완료될 때까지 블로킹, 권한 프롬프트 통과
- **백그라운드**: 병렬 실행, 시작 전 권한 사전 승인 필요 (Ctrl+B)

### 서브에이전트 스폰 제한

```yaml
# 특정 에이전트만 스폰 허용
tools: Task(worker, researcher), Read, Bash
```

```json
// 특정 에이전트 차단
{ "permissions": { "deny": ["Task(Explore)", "Task(my-custom-agent)"] } }
```

### 자동 압축

~95% 용량 도달 시 트리거. 오버라이드:
```bash
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50
```

### 언제 쓸까
- 대량의 출력이 메인 컨텍스트를 오염시킬 때
- 특정 도구/권한 제한이 필요할 때
- 독립적으로 완결되는 작업일 때

### 실전 예제: 멀티 에이전트 병렬 PR 리뷰

에이전트 파일 3개를 만들어두면, 하나의 요청으로 동시에 실행됨.

```yaml
# .claude/agents/security-reviewer.md
---
name: security-reviewer
description: 보안 취약점 전문 리뷰어. 코드 변경 후 보안 검토 필요 시 호출.
tools: Read, Grep, Glob
model: opus
---
OWASP Top 10 기준으로 코드 취약점을 분석하세요.
SQL 인젝션, XSS, 인증/인가 이슈에 특히 집중하세요.
```

```yaml
# .claude/agents/perf-reviewer.md
---
name: perf-reviewer
description: 성능 최적화 전문가. N+1 쿼리, 메모리 누수, 불필요한 렌더링 탐지.
tools: Read, Grep, Glob
model: sonnet
---
성능 병목 지점을 분석하세요.
N+1 쿼리, 불필요한 루프, 캐싱 누락, 메모리 낭비를 집중적으로 찾으세요.
```

```yaml
# .claude/agents/test-validator.md
---
name: test-validator
description: 테스트 커버리지 검토. 새 코드에 테스트가 충분한지 확인.
tools: Read, Grep, Glob, Bash
model: haiku
---
변경된 코드에 대응하는 테스트가 충분한지 확인하세요.
엣지 케이스와 에러 핸들링 테스트 누락 여부를 중점적으로 체크하세요.
```

사용법:
```
이 PR 보안/성능/테스트 커버리지 세 관점으로 동시에 리뷰해줘
→ security-reviewer + perf-reviewer + test-validator 병렬 실행됨
```

---

## 6. Hooks

> 문서: https://code.claude.com/docs/en/hooks

### 핵심 개념
- 특정 이벤트 발생 시 **확정적으로** 실행되는 자동화 스크립트
- LLM 판단 없이 항상 동일하게 실행됨 (Skills/Subagents와의 핵심 차이)
- 3가지 타입: command (셸), prompt (단일 턴 LLM), agent (다중 턴 LLM)

### 이벤트 전체 목록 (17개)

| 이벤트 | 발동 시점 | matcher 대상 |
|--------|----------|-------------|
| `SessionStart` | 세션 시작/재개 | `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | 세션 종료 | `clear`, `logout`, `prompt_input_exit` |
| `UserPromptSubmit` | 프롬프트 제출 시 (처리 전) | — |
| `PreToolUse` | 도구 실행 전 (차단 가능) | 도구명: `Bash`, `Edit\|Write`, `mcp__.*` |
| `PermissionRequest` | 권한 대화상자 표시 시 | — |
| `PostToolUse` | 도구 성공 후 | 도구명 |
| `PostToolUseFailure` | 도구 실패 후 | 도구명 |
| `Stop` | Claude 응답 완료 | — |
| `Notification` | 알림 전송 시 | `permission_prompt`, `idle_prompt` |
| `SubagentStart` | 서브에이전트 시작 | 에이전트 타입 |
| `SubagentStop` | 서브에이전트 완료 | — |
| `TeammateIdle` | 팀원 유휴 상태 전환 | — |
| `TaskCompleted` | 태스크 완료 표시 | — |
| `ConfigChange` | 설정 파일 변경 | `user_settings`, `project_settings`, `skills` |
| `PreCompact` | 컨텍스트 압축 전 | `manual`, `auto` |
| `WorktreeCreate` | Worktree 생성 시 | — |
| `WorktreeRemove` | Worktree 제거 시 | — |

### Exit Code 동작

| Exit Code | 동작 |
|-----------|------|
| `0` | 정상 통과. `UserPromptSubmit`/`SessionStart`에서는 stdout가 컨텍스트에 추가 |
| `2` | 작업 차단. stderr 메시지가 Claude에게 피드백으로 전달 |
| 기타 | 작업 진행. stderr는 로그에만 기록 |

### Hook 타입

| 타입 | 설명 |
|------|------|
| `command` | 셸 명령 실행 |
| `prompt` | 단일 턴 LLM 평가 |
| `agent` | 다중 턴 검증 (도구 접근 가능) |

### 저장 위치

| 위치 | 스코프 | 공유 |
|------|--------|------|
| `~/.claude/settings.json` | 모든 프로젝트 | 아니오 |
| `.claude/settings.json` | 현재 프로젝트 | 예 (repo 커밋) |
| `.claude/settings.local.json` | 현재 프로젝트 | 아니오 (gitignore) |
| Managed policy settings | 조직 전체 | 예 (관리자) |
| Plugin `hooks/hooks.json` | 플러그인 활성화 시 | 예 |
| Skill/Agent frontmatter | 스킬/에이전트 활성 시 | 예 |

### 실용 예제

#### 1. 파일 수정 시 테스트 자동 실행 (Claude가 결과 즉시 인지)

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
Claude가 파일 수정할 때마다 테스트 결과가 자동으로 컨텍스트에 주입됨.
테스트 실패하면 Claude가 바로 인지하고 자동 수정.

#### 2. 작업 완료 시 자동 검증 (agent 타입)

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
Claude 응답 완료될 때마다 테스트 돌려서 실패하면 Claude에게 피드백 전달.

#### 3. 보호 파일 편집 차단

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

#### 4. 편집 후 자동 포맷

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

#### 5. 압축 후 컨텍스트 재주입

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

#### 6. macOS 알림

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

#### 7. PreToolUse 구조화된 출력 (도구 제어)

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep for better performance"
  }
}
```
옵션: `"allow"`, `"deny"`, `"ask"`

---

## 7. MCP (Model Context Protocol)

> 문서: https://code.claude.com/docs/en/mcp

### 핵심 개념
- AI-도구 통합을 위한 오픈 표준
- 외부 서비스(Jira, Slack, Google Drive, DB 등)를 Claude에 연결
- 서브에이전트별 개별 MCP 서버 설정 가능

### 활용 예시

```
# GitHub 이슈 번호 하나로 구현까지
@github:issue://234 이 이슈 구현해줘

# 자연어로 DB 쿼리 (postgres MCP 연결 시)
어제 가입했는데 아직 온보딩 미완료한 사용자 몇 명이야?

# Jira + GitHub + Slack 원스톱
@jira:issue://ENG-1234 보고 구현 후 PR 만들고 @slack:channel://eng-team 에 알려줘

# MCP 프롬프트를 슬래시 커맨드로
/mcp__github__create_issue "로그인 버튼 클릭 시 500 에러" high
```

### 3가지 전송 방식

#### HTTP (권장)
```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

#### SSE (deprecated)
```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

#### 로컬 Stdio
```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

### 스코프 3단계

| 스코프 | 저장소 | 용도 |
|--------|--------|------|
| `local` (기본) | `~/.claude.json` (프로젝트 경로 하위) | 개인, 현재 프로젝트만 |
| `project` | `.mcp.json` (프로젝트 루트) | 팀 공유 (버전 관리) |
| `user` | `~/.claude.json` | 개인, 모든 프로젝트 |

```bash
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

### 관리 명령어

```bash
claude mcp list          # 전체 목록
claude mcp get github    # 특정 서버 상세
claude mcp remove github # 제거
/mcp                     # Claude Code 내에서
```

### `.mcp.json` 설정 예제

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

환경변수 확장:
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

### JSON으로 추가

```bash
claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'
```

### Claude Desktop에서 가져오기

```bash
claude mcp add-from-claude-desktop
```

### Claude Code를 MCP 서버로 사용

```bash
claude mcp serve
```

Claude Desktop 설정:
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

### OAuth 인증

```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

CI 환경:
```bash
MCP_CLIENT_SECRET=your-secret claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

### 리소스 참조 (`@` 문법)

```
> @github:issue://123 분석하고 수정 제안해줘
> @postgres:schema://users와 @docs:file://database/user-model 비교
```

### MCP 프롬프트를 커맨드로 사용

```
> /mcp__github__list_prs
> /mcp__github__pr_review 456
> /mcp__jira__create_issue "Bug in login flow" high
```

### 출력 제한

| 설정 | 기본값 |
|------|--------|
| 경고 임계값 | 10,000 토큰 |
| 최대 출력 | 25,000 토큰 |
| 커스텀 | `export MAX_MCP_OUTPUT_TOKENS=50000` |

### Tool Search

| 값 | 동작 |
|----|------|
| `auto` | MCP 도구가 컨텍스트의 10% 초과 시 활성화 (기본) |
| `auto:<N>` | 커스텀 임계값 비율 |
| `true` | 항상 활성화 |
| `false` | 비활성화, 모든 도구 사전 로드 |

```bash
ENABLE_TOOL_SEARCH=auto:5 claude
ENABLE_TOOL_SEARCH=false claude
```

### 관리자 MCP 설정

파일 위치:
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
Denylist가 allowlist보다 항상 우선. URL 패턴에 `*` 와일드카드 지원.

---

## 8. Plugins

> 문서: https://code.claude.com/docs/en/plugins

### 핵심 개념
- Skills + Subagents + Hooks + MCP를 패키징해 배포하는 단위
- Standalone(`.claude/` 직접) vs Plugin(패키지화) 선택 가능

### Standalone vs Plugin

| 방식 | 스킬명 | 적합한 경우 |
|------|--------|------------|
| Standalone (`.claude/` 디렉토리) | `/hello` | 개인 워크플로우, 프로젝트 한정, 빠른 실험 |
| Plugin (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | 공유, 배포, 버전 관리, 재사용 |

### 디렉토리 구조

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # 매니페스트 (필수)
├── commands/                # Skills (마크다운 파일)
├── agents/                  # 커스텀 에이전트 정의
├── skills/                  # Agent Skills (SKILL.md)
├── hooks/
│   └── hooks.json           # 이벤트 핸들러
├── .mcp.json                # MCP 서버 설정
├── .lsp.json                # LSP 서버 설정
└── settings.json            # 플러그인 활성화 시 기본 설정
```

### plugin.json 매니페스트

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

### 로컬 테스트

```bash
claude --plugin-dir ./my-plugin
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### LSP 서버 설정 (`.lsp.json`)

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

### 기본 설정 (`settings.json`)

```json
{
  "agent": "security-reviewer"
}
```

### 플러그인 내 MCP 서버

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

또는 `plugin.json` 인라인:
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

### Standalone → Plugin 마이그레이션

```bash
mkdir -p my-plugin/.claude-plugin
cp -r .claude/commands my-plugin/
cp -r .claude/agents my-plugin/
cp -r .claude/skills my-plugin/
mkdir my-plugin/hooks
```

Hooks 마이그레이션 — `.claude/settings.json`에서 `my-plugin/hooks/hooks.json`으로 복사:
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

---

# Part 3: 고급 기능

---

## 9. Agent Teams (실험적)

> 문서: https://code.claude.com/docs/en/agent-teams
> 활성화: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

### 핵심 개념
- 팀원들이 **서로 직접 통신**하며 협력 (Subagents와의 핵심 차이)
- 공유 태스크 리스트로 자율 조율
- 각 팀원이 독립적인 컨텍스트 창 보유

### Subagents vs Agent Teams

| | Subagents | Agent Teams |
|---|---|---|
| 컨텍스트 | 자체 창; 결과만 반환 | 자체 창; 완전 독립 |
| 통신 | 메인에게만 보고 | 팀원끼리 직접 메시지 |
| 조율 | 메인이 관리 | 공유 태스크 리스트로 자율 |
| 용도 | 결과만 중요한 집중 작업 | 토론/협업 필요한 복잡한 작업 |
| 토큰 비용 | 낮음 | 높음 |

### 구성요소

| 컴포넌트 | 역할 |
|----------|------|
| Team lead | 팀 생성, 팀원 스폰, 조율 |
| Teammates | 독립적인 Claude Code 인스턴스 |
| Task list | 공유 작업 목록 (claim/complete) |
| Mailbox | 에이전트 간 메시징 시스템 |

### 활성화

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### 디스플레이 모드

| 모드 | 설명 |
|------|------|
| **in-process** | 메인 터미널에서 Shift+Down으로 팀원 전환 |
| **split panes** | tmux 또는 iTerm2로 분할 화면 |

```json
{ "teammateMode": "in-process" }
```
```bash
claude --teammate-mode in-process
```

### 저장 위치

- 팀 설정: `~/.claude/teams/{team-name}/config.json`
- 태스크 리스트: `~/.claude/tasks/{team-name}/`

### 강점 케이스
- 병렬 코드 리뷰 (보안 / 성능 / 테스트 각각)
- 경쟁 가설로 버그 디버깅
- 프론트/백엔드/테스트 동시 작업

### 제한사항 (실험적)
- 세션 재개 시 in-process 팀원 복원 불가
- 태스크 상태 지연 가능성
- 종료가 느릴 수 있음
- 세션당 하나의 팀만 가능
- 중첩 팀 불가 (팀원이 또 팀 못 만듦)
- 리더 고정 (변경 불가)
- 스폰 시 권한 설정
- split pane은 tmux/iTerm2 필요

---

## 10. Headless / Agent SDK

> 문서: https://code.claude.com/docs/en/headless

### 핵심 개념
- `-p` 플래그로 프로그래밍 방식 실행 (비대화형)
- CI/CD, 스크립트, 파이프라인에서 활용
- 구조화된 출력(JSON, 스트림) 지원

### 기본 사용법

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

### 구조화된 출력

```bash
# 일반 텍스트 (기본)
claude -p "Summarize this project" --output-format text

# 메타데이터 포함 JSON
claude -p "Summarize this project" --output-format json

# JSON 스키마로 구조화
claude -p "Extract the main function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'

# 특정 필드 추출
claude -p "Summarize this project" --output-format json | jq -r '.result'
```

### 스트리밍 응답

```bash
claude -p "Explain recursion" --output-format stream-json --verbose --include-partial-messages

# 텍스트 델타만 필터링
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

### 도구 자동 승인 (`--allowedTools`)

```bash
claude -p "Run the test suite and fix any failures" \
  --allowedTools "Bash,Read,Edit"
```

### 커밋 자동화 예시

```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

### 시스템 프롬프트 커스터마이즈

```bash
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

### 세션 계속

```bash
# 가장 최근 세션 이어서
claude -p "Review this codebase for performance issues"
claude -p "Now focus on the database queries" --continue

# 특정 세션 재개
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Unix 파이프 패턴

```bash
# 빌드 에러 분석
cat build-error.txt | claude -p 'concisely explain the root cause' > output.txt

# 보안 리뷰
git diff main --name-only | claude -p "review these changed files for security issues"

# npm 스크립트로 활용
# package.json
{
  "scripts": {
    "lint:claude": "claude -p 'you are a linter. please look at the changes vs. main and report any issues related to typos.'"
  }
}
```

### CI/CD 활용 예시

```bash
# 번역 자동화
claude -p "translate new strings into French and raise a PR for review"

# PR 보안 리뷰
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

---

## 11. Common Workflows

> 문서: https://code.claude.com/docs/en/common-workflows

### 5대 워크플로우

#### 1. 코드베이스 이해

```
> give me an overview of this codebase
> explain the main architecture patterns used here
> what are the key data models?
> find the files that handle user authentication
> trace the login process from front-end to database
```

#### 2. 버그 수정

```
> I'm seeing an error when I run npm test
> suggest a few ways to fix the @ts-ignore in user.ts
> update user.ts to add the null check you suggested
```

#### 3. 리팩토링

```
> find deprecated API usage in our codebase
> suggest how to refactor utils.js to use modern JavaScript features
> refactor utils.js to use ES2024 features while maintaining the same behavior
> run tests for the refactored code
```

#### 4. 테스트 작성

검증 기준 포함 프롬프트가 핵심:
```
> write tests for the auth module. run them after implementation.
> add edge case tests for null/undefined inputs in validator.ts
```

#### 5. PR 생성

```
> /commit-push-pr
> create a pr
```
`gh pr create`로 생성된 세션은 PR에 연결됨. `claude --from-pr <number>`로 재개 가능.

### Plan Mode

```bash
# CLI에서 시작
claude --permission-mode plan

# 세션 중 토글: Shift+Tab
# 텍스트 에디터에서 계획 열기: Ctrl+G
```

기본값으로 설정:
```json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

### Extended Thinking 설정

| 스코프 | 설정 방법 | 상세 |
|--------|----------|------|
| 노력 수준 | `/model` 또는 `CLAUDE_CODE_EFFORT_LEVEL` | low, medium, high (기본) |
| 토글 단축키 | `Option+T` (macOS) / `Alt+T` (Win/Linux) | 현재 세션 토글 |
| 글로벌 기본 | `/config` | 모든 프로젝트 기본값 |
| 토큰 예산 제한 | `MAX_THINKING_TOKENS` 환경변수 | 특정 토큰으로 제한 |

### 이미지 분석

- 드래그 앤 드롭으로 Claude Code 창에 넣기
- `Ctrl+V`로 복사/붙여넣기
- 경로 제공: "Analyze this image: /path/to/image.png"

### 세션 관리

```bash
claude --continue    # 가장 최근 세션 재개
claude --resume      # 최근 세션 목록에서 선택
claude --from-pr 123 # PR 연결 세션 재개
```

세션 선택기 단축키:
| 단축키 | 동작 |
|--------|------|
| Up/Down | 세션 탐색 |
| Right/Left | 그룹 확장/축소 |
| Enter | 선택 및 재개 |
| P | 세션 미리보기 |
| R | 세션 이름 변경 |
| / | 검색 필터 |
| A | 현재 디렉토리 / 전체 프로젝트 토글 |
| B | 현재 브랜치 필터 |

### Git Worktree 병렬 세션

```bash
claude --worktree feature-auth
claude --worktree bugfix-123
claude --worktree  # 자동 이름 생성
```

- `<repo>/.claude/worktrees/<name>`에 생성
- 기본 원격 브랜치에서 분기
- 서브에이전트: `isolation: worktree` 프론트매터로 사용

### `@` 문법 참조

```
> explain the main architecture in @src/index.ts
> review @src/middleware/rateLimiter.ts
```

### 알림 Hook 설정

| matcher | 발동 시점 |
|---------|----------|
| `permission_prompt` | Claude가 승인 필요 |
| `idle_prompt` | Claude 완료, 다음 입력 대기 |
| `auth_success` | 인증 완료 |
| `elicitation_dialog` | Claude가 질문 중 |

---

# Part 4: 플랫폼 & 통합

---

## 12. 플랫폼

> 문서: https://code.claude.com/docs/en/overview

### 사용 가능한 표면

| 목적 | 최적 옵션 |
|------|-----------|
| 다른 기기에서 로컬 세션 이어받기 | Remote Control |
| 로컬 시작 → 모바일 계속 | Web 또는 Claude iOS 앱 |
| PR 리뷰, 이슈 트리아지 자동화 | GitHub Actions / GitLab CI/CD |
| Slack 버그 리포트 → PR | Slack |
| 라이브 웹앱 디버깅 | Chrome |
| 커스텀 에이전트 빌드 | Agent SDK |

### 설치 방법

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

### IDE 통합

| IDE | 설치 방법 |
|-----|----------|
| **VS Code** | Extensions에서 "Claude Code" 검색 → Command Palette > "Open in New Tab" |
| **JetBrains** | JetBrains Marketplace에서 플러그인 설치 (IntelliJ, PyCharm, WebStorm 등) |
| **Desktop** | macOS (Intel + Apple Silicon), Windows (x64, ARM64) 다운로드 |

### Web

[claude.ai/code](https://claude.ai/code)에서 브라우저 실행. 로컬 설치 불필요.

### 크로스 표면 기능

| 기능 | 설명 |
|------|------|
| `/teleport` | Web/iOS 세션을 터미널로 당기기 |
| `/desktop` | 터미널 세션을 Desktop 앱으로 넘기기 |
| `@Claude` (Slack) | 채팅에서 PR 받기 |
| Remote Control | 폰에서 계속하기 |

모든 표면이 동일한 CLAUDE.md 파일, 설정, MCP 서버를 공유.

### 관련 문서 링크

| 기능 | 문서 |
|------|------|
| Remote Control | [remote-control](https://code.claude.com/docs/en/remote-control) |
| Web | [claude-code-on-the-web](https://code.claude.com/docs/en/claude-code-on-the-web) |
| Chrome | [chrome](https://code.claude.com/docs/en/chrome) |
| Desktop | [desktop](https://code.claude.com/docs/en/desktop) |

---

## 13. CI/CD

> GitHub Actions: https://code.claude.com/docs/en/github-actions
> GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd
> Action 레포: https://github.com/anthropics/claude-code-action

### GitHub Actions

#### 핵심 개념

- `@claude` 멘션으로 PR/이슈에서 코드 분석, PR 생성, 기능 구현, 버그 수정
- CLAUDE.md 가이드라인과 기존 코드 패턴을 준수
- Agent SDK 기반으로 커스텀 자동화 워크플로우 구축 가능
- 기본 모델은 Sonnet, Opus 사용 시 `--model claude-opus-4-6` 설정

#### 빠른 설정

```bash
# Claude Code 터미널에서 실행 (가장 쉬운 방법)
/install-github-app
```
> 레포 admin 권한 필요. GitHub App이 Contents, Issues, Pull requests에 대한 Read & Write 권한 요청.

**수동 설정**:
1. [Claude GitHub App](https://github.com/apps/claude) 설치
2. `ANTHROPIC_API_KEY`를 레포 Secrets에 추가
3. [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml)을 `.github/workflows/`에 복사

#### 기본 워크플로우

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
          # @claude 멘션에 자동 응답
```

#### Skills 활용 워크플로우

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

#### 스케줄 자동화 워크플로우

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

#### Action 파라미터 (v1)

| 파라미터 | 설명 | 필수 |
|----------|------|------|
| `prompt` | Claude에 대한 지시 (텍스트 또는 `/review` 같은 스킬) | 아니오* |
| `claude_args` | Claude Code CLI 인수 전달 | 아니오 |
| `anthropic_api_key` | Claude API 키 | 예** |
| `github_token` | GitHub API 접근 토큰 | 아니오 |
| `trigger_phrase` | 트리거 문구 (기본: "@claude") | 아니오 |
| `use_bedrock` | AWS Bedrock 사용 | 아니오 |
| `use_vertex` | Google Vertex AI 사용 | 아니오 |

\*prompt 생략 시 이슈/PR 댓글에서 트리거 문구에 응답
\*\*Claude API 직접 사용 시 필수, Bedrock/Vertex 사용 시 불필요

**주요 CLI 인수** (`claude_args`):
```yaml
claude_args: "--max-turns 5 --model claude-sonnet-4-6 --mcp-config /path/to/config.json"
```
- `--max-turns`: 최대 대화 턴 (기본: 10)
- `--model`: 사용 모델
- `--mcp-config`: MCP 설정 파일 경로
- `--allowed-tools`: 허용 도구 쉼표 구분 목록
- `--debug`: 디버그 출력

#### 사용 예시 (이슈/PR 댓글)

```text
@claude implement this feature based on the issue description
@claude how should I implement user authentication for this endpoint?
@claude fix the TypeError in the user dashboard component
```

#### AWS Bedrock / Google Vertex AI 연동

**AWS Bedrock 워크플로우**:
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
> Bedrock 모델 ID는 리전 접두사 포함: `us.anthropic.claude-sonnet-4-6`

**Google Vertex AI**: GCP Workload Identity Federation으로 인증. `use_vertex: "true"` 설정, `ANTHROPIC_VERTEX_PROJECT_ID`, `CLOUD_ML_REGION` 환경변수 필요.

#### 비용 고려사항

| 비용 항목 | 설명 |
|-----------|------|
| GitHub Actions 분 | GitHub-hosted runner 컴퓨트 시간 소비 |
| API 토큰 | 프롬프트/응답 길이에 따른 토큰 비용 |

**최적화 팁**:
- 구체적인 `@claude` 명령으로 불필요한 API 호출 줄이기
- `--max-turns`로 과도한 반복 방지
- 워크플로우 수준 timeout으로 폭주 작업 방지
- GitHub concurrency control로 병렬 실행 제한

#### 트러블슈팅

| 문제 | 확인사항 |
|------|---------|
| `@claude` 응답 없음 | GitHub App 설치 확인, 워크플로우 활성화, API 키 시크릿 확인, `/claude` 아닌 `@claude` 사용 확인 |
| Claude 커밋에 CI 미실행 | GitHub App 사용 확인 (기본 Actions 사용자 아님), 워크플로우 트리거 이벤트 확인 |
| 인증 에러 | API 키 유효성/권한 확인, Bedrock/Vertex 자격증명 설정 확인 |

---

### GitLab CI/CD

> 베타 상태. GitLab이 유지보수. [GitLab issue](https://gitlab.com/gitlab-org/gitlab/-/issues/573776) 참고.

#### 핵심 개념

- `@claude` 멘션으로 이슈/MR에서 코드 구현, MR 생성, 버그 수정
- 격리된 컨테이너에서 샌드박스 실행
- Claude API, AWS Bedrock, Google Vertex AI 모두 지원
- 모든 변경은 MR을 통해 리뷰 가능

#### 동작 방식

1. **이벤트 기반**: `@claude` 댓글 → 컨텍스트 수집 → 프롬프트 구성 → Claude Code 실행
2. **프로바이더 추상화**: Claude API (SaaS) / AWS Bedrock / Google Vertex AI 선택
3. **샌드박스 실행**: 격리 컨테이너, 네트워크/파일시스템 제한, workspace 범위 권한

#### 빠른 설정

1. **Settings → CI/CD → Variables**에서 `ANTHROPIC_API_KEY` 추가 (masked)
2. `.gitlab-ci.yml`에 Claude job 추가:

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

#### AWS Bedrock 워크플로우 (OIDC)

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

필요 CI/CD Variables: `AWS_ROLE_TO_ASSUME`, `AWS_REGION`

#### Google Vertex AI 워크플로우 (WIF)

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

필요 CI/CD Variables: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION`

#### 사용 예시 (이슈/MR 댓글)

```text
@claude implement this feature based on the issue description
@claude suggest a concrete approach to cache the results of this API call
@claude fix the TypeError in the user dashboard component
```

#### 보안 & 거버넌스

- 각 job은 격리된 컨테이너에서 실행 (네트워크/파일시스템 제한)
- 모든 변경은 MR을 통해 리뷰어가 diff 확인
- Branch protection 및 approval 규칙이 AI 생성 코드에도 적용
- Workspace 범위 권한으로 쓰기 제한
- 본인의 프로바이더 자격증명 사용으로 비용 통제

#### 트러블슈팅

| 문제 | 확인사항 |
|------|---------|
| `@claude` 응답 없음 | 파이프라인 트리거 확인, CI/CD Variables 존재 확인, `@claude` 사용 (`/claude` 아님) |
| 댓글/MR 작성 불가 | `CI_JOB_TOKEN` 권한 확인 또는 `api` scope PAT 사용, `mcp__gitlab` 도구 활성화 확인 |
| 인증 에러 | API 키 유효성 확인, OIDC/WIF 설정 확인, 리전/모델 가용성 확인 |

---

### GitHub Actions vs GitLab CI/CD 비교

| 측면 | GitHub Actions | GitLab CI/CD |
|------|---------------|-------------|
| 상태 | GA (v1) | 베타 |
| 유지보수 | Anthropic | GitLab |
| 설정 방식 | `/install-github-app` 또는 수동 | `.gitlab-ci.yml` 직접 작성 |
| 트리거 | `@claude` 멘션 자동 감지 | 웹훅/파이프라인 트리거 설정 필요 |
| Action/Job | `anthropics/claude-code-action@v1` | 직접 `claude` CLI 실행 |
| 프로바이더 | Claude API, Bedrock, Vertex | Claude API, Bedrock, Vertex |
| 보안 | GitHub Secrets + App 권한 | CI/CD Variables + 컨테이너 격리 |

---

## 14. Slack 통합

> 문서: https://code.claude.com/docs/en/slack
> Slack Marketplace: https://slack.com/marketplace/A08SF47R6P4

### 핵심 개념

- `@Claude` 멘션 → 코딩 의도 자동 감지 → Claude Code 웹 세션 생성
- Slack 대화 컨텍스트를 활용한 코딩 작업 위임
- 기존 Claude for Slack 앱 위에 구축, 코딩 요청을 Claude Code 웹으로 라우팅

### 전제 조건

| 요구사항 | 상세 |
|---------|------|
| Claude 플랜 | Pro, Max, Teams, Enterprise (Claude Code 접근 포함, premium seats) |
| Claude Code 웹 | [claude.ai/code](https://claude.ai/code) 접근 활성화 필요 |
| GitHub 계정 | Claude Code 웹에 연결, 최소 1개 레포 인증 |
| Slack 인증 | Slack 계정과 Claude 계정 연결 |

### 설정 방법

1. **Slack App 설치**: 워크스페이스 관리자가 [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)에서 설치
2. **Claude 계정 연결**: Slack → Apps → Claude → App Home → "Connect" 클릭
3. **Claude Code 웹 설정**: [claude.ai/code](https://claude.ai/code) 접속 → GitHub 계정 연결 → 레포 인증
4. **라우팅 모드 선택**: App Home에서 설정
5. **채널에 추가**: `/invite @Claude`로 원하는 채널에 초대 (자동 추가 안 됨)

### 라우팅 모드

| 모드 | 동작 |
|------|------|
| **Code only** | 모든 `@Claude` 멘션을 Claude Code 세션으로 라우팅. 개발 전용 팀에 적합 |
| **Code + Chat** | 메시지 분석 후 코딩 작업은 Claude Code로, 일반 질문은 Claude Chat으로 지능적 라우팅 |

> Code + Chat 모드에서 잘못 라우팅된 경우: "Retry as Code" 또는 Chat 선택 가능

### 동작 흐름

1. **시작**: `@Claude` 멘션으로 코딩 요청
2. **감지**: Claude가 메시지 분석 → 코딩 의도 감지
3. **세션 생성**: claude.ai/code에 새 Claude Code 세션 생성
4. **진행 업데이트**: Slack 스레드에 상태 업데이트 게시
5. **완료**: 요약 + 액션 버튼과 함께 `@멘션`으로 알림
6. **리뷰**: "View Session"으로 전체 기록 확인, "Create PR"로 풀 리퀘스트 생성

### 컨텍스트 수집

| 출처 | 동작 |
|------|------|
| **스레드** | 스레드의 모든 메시지에서 컨텍스트 수집 |
| **채널** | 채널의 최근 메시지에서 관련 컨텍스트 수집 |

> 주의: `@Claude` 호출 시 대화 컨텍스트에 접근. 신뢰할 수 있는 Slack 대화에서만 사용.

### UI 요소

| 액션 | 기능 |
|------|------|
| **View Session** | 브라우저에서 전체 Claude Code 세션 열기 (기록 확인, 계속, 추가 요청) |
| **Create PR** | 세션 변경사항으로 PR 바로 생성 |
| **Retry as Code** | Chat으로 라우팅된 것을 Code 세션으로 재시도 |
| **Change Repo** | Claude가 잘못 선택한 레포 변경 |

### 접근 권한

**사용자 수준**:
| 접근 유형 | 설명 |
|----------|------|
| 세션 | 각 사용자 본인의 Claude 계정으로 실행 |
| 사용량/Rate Limit | 개인 플랜 한도에 포함 |
| 레포 접근 | 본인이 연결한 레포만 접근 가능 |
| 세션 기록 | claude.ai/code의 히스토리에 표시 |

**워크스페이스 수준**:
- 워크스페이스 관리자가 Claude 앱 설치/제거 제어
- Enterprise Grid: 조직 관리자가 워크스페이스별 접근 제어
- 앱 제거 시 해당 워크스페이스 전체 사용자 접근 즉시 해제

**채널 기반 접근 제어**:
- Claude는 초대된 채널에서만 응답 (`/invite @Claude`)
- 공개/비공개 채널 모두 지원
- 관리자가 채널 접근 관리로 Claude Code 사용 제한 가능

### 활용 사례

| 사례 | 설명 |
|------|------|
| 버그 조사/수정 | Slack 채널에 보고된 버그 즉시 조사 및 수정 |
| 코드 리뷰/수정 | 팀 피드백 기반 소규모 기능 구현, 리팩토링 |
| 협업 디버깅 | 에러 재현, 사용자 리포트 등 팀 토론 컨텍스트 활용 |
| 병렬 작업 | Slack에서 코딩 작업 시작 → 다른 작업 계속 → 완료 시 알림 |

### Slack vs 웹 직접 사용

| Slack 사용 | 웹 직접 사용 |
|-----------|------------|
| 컨텍스트가 이미 Slack 토론에 있을 때 | 파일 업로드가 필요할 때 |
| 비동기 작업 시작 시 | 개발 중 실시간 상호작용 필요 시 |
| 팀원 가시성이 필요할 때 | 길고 복잡한 작업 시 |

### 효과적인 요청 작성

- **구체적으로**: 파일명, 함수명, 에러 메시지 포함
- **컨텍스트 제공**: 레포나 프로젝트 명시 (대화에서 불분명할 경우)
- **성공 정의**: 테스트 작성? 문서 업데이트? PR 생성?
- **스레드 활용**: 버그/기능 논의 시 스레드 사용 → Claude가 전체 컨텍스트 수집

### 현재 제한사항

- **GitHub만 지원**: 현재 GitHub 레포만 가능
- **PR 1개**: 세션당 하나의 PR 생성
- **Rate Limit**: 개인 Claude 플랜 한도 적용
- **웹 접근 필수**: Claude Code 웹 접근 없으면 일반 Claude Chat 응답만
- **DM 미지원**: 채널에서만 작동 (공개/비공개 모두 가능)

### 트러블슈팅

| 문제 | 해결 |
|------|------|
| 세션 시작 안 됨 | App Home에서 Claude 계정 연결 확인 → 웹 접근 확인 → GitHub 레포 연결 확인 |
| 레포 안 보임 | claude.ai/code에서 레포 연결 → GitHub 권한 확인 → GitHub 계정 재연결 |
| 잘못된 레포 선택 | "Change Repo" 버튼 → 요청에 레포명 포함 |
| 인증 에러 | App Home에서 연결 해제/재연결 → 올바른 Claude 계정 확인 → Claude Code 접근 포함 플랜 확인 |

---

# 부록

---

## 부록 A: 기능 선택 가이드 (언제 뭘 쓸까?)

| 니즈 | 사용 기능 | 이유 |
|------|-----------|------|
| "항상 따라야 할 규칙" | **CLAUDE.md** | 매 세션 자동 로드, "Always do X" |
| "필요할 때 로드하는 참고/워크플로우" | **Skills** | 온디맨드 로드, `/<name>` 호출 |
| "외부 시스템 연결" | **MCP** | Jira, Slack, DB 등 외부 도구 |
| "병렬 격리 작업" | **Subagents** | 독립 컨텍스트, 메인 오염 방지 |
| "확정적 자동화 (LLM 판단 없이)" | **Hooks** | 이벤트 기반 확정적 실행 |
| "토론/협업 필요한 복잡한 작업" | **Agent Teams** | 팀원 간 직접 통신, 자율 조율 |
| "재사용/공유/배포" | **Plugins** | 패키징 단위, 버전 관리 |
| "CI/CD에서 비대화형 실행" | **Headless (`-p`)** | 프로그래밍 방식 실행 |

### 의사결정 트리

```
지시사항을 만들고 싶다
├── 항상 적용? → CLAUDE.md
├── 특정 경로에만? → .claude/rules/*.md
├── 필요할 때만? → Skills
└── 여러 프로젝트에 공유? → Plugins

작업을 자동화하고 싶다
├── LLM 판단 필요 없이 확정적? → Hooks
├── 외부 시스템과 연결? → MCP
├── 독립적 탐색/작업? → Subagents
└── 팀 협업 필요? → Agent Teams

CI/CD에서 실행하고 싶다
└── Headless (-p) + --allowedTools
```

---

## 부록 B: 컨텍스트 최적화 전략

### 기능별 로드 시점/비용

| 기능 | 로드 시점 | 컨텍스트 비용 |
|------|----------|-------------|
| CLAUDE.md | 매 세션 시작 | 전체 내용 (500줄 이하 유지!) |
| Auto Memory (MEMORY.md) | 매 세션 시작 | 첫 200줄만 |
| Skills (설명문) | 매 세션 시작 | 컨텍스트 2% (폴백 16K자) |
| Skills (전체 내용) | 호출 시 | 호출된 스킬만큼 |
| Subagents | 위임 시 | 메인에 결과만 반환 (격리) |
| Rules (`.claude/rules/`) | 해당 경로 파일 작업 시 | 매칭된 규칙만큼 |
| Hooks | 이벤트 발생 시 | 없음 (외부 실행) |
| MCP 도구 목록 | 세션 시작 | Tool Search로 최적화 가능 |

### 핵심 원칙

1. **CLAUDE.md 500줄 이하 유지** — 참고자료는 Skills로 분리
2. **관련 없는 작업 사이에 `/clear`** — 컨텍스트 오염 방지
3. **대량 출력 작업은 Subagent로 격리** — 메인 컨텍스트 보호
4. **경로 조건부 Rules 활용** — 불필요한 규칙 로드 방지
5. **`/compact <지시>` 적극 활용** — 중간 정리
6. **MCP Tool Search 활성화** — 도구 10개 이상일 때

---

## 부록 C: 기능 간 비교 매트릭스

### Skills vs Subagents

| 측면 | Skills | Subagents |
|------|--------|-----------|
| 정체 | 재사용 가능한 지시/지식/워크플로우 | 격리된 작업자 (자체 컨텍스트) |
| 핵심 이점 | 컨텍스트 간 콘텐츠 공유 | 컨텍스트 격리 |
| 적합 | 참고자료, 호출 가능한 워크플로우 | 많은 파일 읽기, 병렬 작업 |

### CLAUDE.md vs Skills

| 측면 | CLAUDE.md | Skills |
|------|-----------|--------|
| 로드 | 매 세션, 자동 | 온디맨드 |
| 워크플로우 트리거 | 불가 | `/<name>`으로 가능 |
| 적합 | "항상 X 하라" 규칙 | 참고자료, 호출 가능한 워크플로우 |

**경험 법칙**: CLAUDE.md는 ~500줄 이하. 그 이상은 Skills로 분리.

### Subagents vs Agent Teams

| 측면 | Subagents | Agent Teams |
|------|-----------|-------------|
| 통신 | 메인에게만 보고 | 팀원끼리 직접 메시지 |
| 조율 | 메인이 관리 | 공유 태스크 리스트 |
| 비용 | 낮음 | 높음 |
| 적합 | 결과만 중요한 집중 작업 | 토론/협업 필요한 복잡한 작업 |

### MCP vs Skills

| 측면 | MCP | Skills |
|------|-----|--------|
| 목적 | 외부 서비스 연결 (API) | 내부 지시/워크플로우 |
| 실행 | 도구 호출 (외부 서버) | 프롬프트 주입 |
| 예시 | Jira 이슈 읽기, DB 쿼리 | 코드 리뷰 체크리스트, 배포 가이드 |

### Hooks vs Skills

| 측면 | Hooks | Skills |
|------|-------|--------|
| 실행 방식 | 확정적 (LLM 판단 없음) | LLM이 판단/실행 |
| 트리거 | 이벤트 기반 (자동) | `/명령어` 또는 Claude 자동 호출 |
| 적합 | 포맷팅, 보호, 알림, 로깅 | 워크플로우, 참고자료, 분석 |

### 전체 기능 비교 요약

| 기능 | 하는 일 | 사용 시점 | 예시 |
|------|--------|----------|------|
| CLAUDE.md | 영속 컨텍스트 | "항상 X 하라" 규칙 | "pnpm 사용, npm 말고" |
| Skill | 지시/지식/워크플로우 | 재사용 콘텐츠, 반복 작업 | `/review`로 코드 리뷰 체크리스트 |
| Subagent | 격리 실행 컨텍스트 | 컨텍스트 격리, 병렬 작업 | 많은 파일 읽는 리서치 |
| Agent Teams | 다중 독립 세션 조율 | 병렬 리서치, 경쟁 가설 | 보안/성능/테스트 동시 리뷰 |
| MCP | 외부 서비스 연결 | 외부 데이터/액션 | DB 쿼리, Slack 포스트 |
| Hook | 이벤트 기반 스크립트 | 예측 가능한 자동화 | 편집 후 ESLint 실행 |

---

## 실습: GitHub Actions + CLAUDE_CODE_OAUTH_TOKEN 설정 (2026-02-28)

### 배경

`ANTHROPIC_API_KEY` 대신 `CLAUDE_CODE_OAUTH_TOKEN`(Claude.ai 계정 OAuth)으로 인증하는 방식으로 설정.

### 최종 작동 워크플로우

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
      id-token: write   # ← CLAUDE_CODE_OAUTH_TOKEN 사용 시 필수
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          claude_args: "--max-turns 10"
```

### 트러블슈팅

| 에러 | 원인 | 해결 |
|------|------|------|
| `Unable to get ACTIONS_ID_TOKEN_REQUEST_URL` | `id-token: write` 권한 누락 | permissions에 `id-token: write` 추가 |
| `Bad credentials` | OAuth 토큰 미설정 또는 빈 값 | GitHub Secrets에 `CLAUDE_CODE_OAUTH_TOKEN` 등록 확인 |
| `issue_comment` 이벤트가 구 워크플로우 실행 | main 브랜치 워크플로우 기준으로 트리거됨 | 수정 사항을 반드시 main에 push 후 테스트 |

### 인증 방식 비교

| 방식 | 시크릿 이름 | 추가 권한 | 특징 |
|------|------------|-----------|------|
| API 키 | `ANTHROPIC_API_KEY` | 불필요 | 직접 API 사용 |
| OAuth 토큰 | `CLAUDE_CODE_OAUTH_TOKEN` | `id-token: write` 필요 | Claude.ai 계정 연동 |

### 핵심 교훈

- `issue_comment` 이벤트는 **main 브랜치** 워크플로우를 사용 → 수정 후 main에 먼저 반영해야 테스트 가능
- `CLAUDE_CODE_OAUTH_TOKEN` 사용 시 OIDC 토큰이 필요하므로 `id-token: write` 필수
- `.claude/settings.json`의 deny 규칙(`git push *`)은 Claude가 직접 push하는 것을 막음 → 의도한 보호 장치
| Plugin | 패키징 & 배포 | 공유, 버전 관리 | 팀 공통 도구 모음 |
