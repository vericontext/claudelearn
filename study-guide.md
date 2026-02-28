# Claude Code 학습 가이드

> `note-reference.md` — 공개용 원본 (수정하지 말 것)
> `note.md` — 작업용 (개인 메모, 체크 표시 등 자유롭게)

---

## 학습 원칙

1. **읽기만으로는 안 된다** — 반드시 직접 설정하고 실행해볼 것
2. **한 번에 하나씩** — 기능 하나를 완전히 체득한 후 다음으로
3. **실제 프로젝트에 적용** — 연습용이 아닌 지금 하는 작업에 바로 적용

---

## Phase 1: 기초 세팅 (Day 1~2)

> 목표: Claude Code를 "나에게 맞게" 세팅하는 것

### 1-1. Memory / CLAUDE.md

**읽기**: note.md 섹션 1

**실습**:
- [x] 현재 프로젝트에 `CLAUDE.md` 작성 (5줄 이하로 시작)
- [x] `~/.claude/CLAUDE.md` 개인 전역 설정 작성
- [x] `/init` 실행해서 자동 생성 결과 확인
- [x] `.claude/rules/` 디렉토리에 경로별 규칙 1개 만들어보기
- [x] `/memory` 실행해서 Auto Memory 상태 확인

**체크포인트**: 새 세션 시작 시 Claude가 내 규칙을 따르는지 확인

### 1-2. Permissions

**읽기**: note.md 섹션 2

**실습**:
- [x] 현재 권한 모드 확인 (`default`인지)
- [x] `.claude/settings.json`에 자주 쓰는 명령 allow 규칙 추가
- [x] deny 규칙 1개 추가 (예: `Bash(rm -rf *)`)
- [ ] `acceptEdits` 모드로 전환해보고 차이 체감

**체크포인트**: 허용/거부가 의도대로 동작하는지 확인

### 1-3. Best Practices

**읽기**: note.md 섹션 3

**실습**:
- [x] 다음 작업에서 "탐색 → 계획 → 구현 → 커밋" 4단계 의식적으로 적용
- [x] `/clear` 습관화 — 작업 전환 시 반드시 실행
- [x] 나쁜 프롬프트 vs 좋은 프롬프트 비교 테이블 보고, 다음 프롬프트 작성 시 적용

**체크포인트**: 한 세션에서 컨텍스트 오염 없이 작업 완료

---

## Phase 2: 핵심 확장 기능 (Day 3~7)

> 목표: 가장 자주 쓸 기능 3개를 자유자재로 사용

### 2-1. Skills

**읽기**: note.md 섹션 4

**실습**:
- [x] 간단한 스킬 1개 만들기: `.claude/skills/hello/SKILL.md`
  ```yaml
  ---
  name: hello
  description: 인사하는 스킬
  ---
  사용자에게 한국어로 친근하게 인사하세요.
  ```
- [x] `/hello` 실행해서 동작 확인
- [x] 실전 스킬 만들기 — note.md 실전 예제 참고:
  - `/ship`: staged/unstaged diff 읽어 자동 커밋 + PR 생성
  - `/review [pr-number]`: PR diff/댓글 분석 후 리뷰 코멘트
- [x] `!`command`` 동적 컨텍스트 주입 사용해보기
- [x] `$ARGUMENTS` 인수 전달 사용해보기
- [ ] `disable-model-invocation: true` vs 기본 차이 확인

**체크포인트**: `/ship`으로 실제 커밋 + PR 생성까지 한 커맨드에 완료

### 2-2. Hooks

**읽기**: note.md 섹션 6

**실습**:
- [x] 파일 수정 시 테스트 자동 실행 (`PostToolUse` + `Edit|Write` matcher)
  - Claude가 파일 고칠 때마다 테스트 결과가 컨텍스트에 자동 주입됨
- [ ] 작업 완료 시 자동 검증 (`Stop` + `type: agent`)
  - 응답 완료마다 테스트 돌려서 실패 시 Claude에게 피드백
- [ ] 자동 포맷 훅 설정 (prettier/eslint 연동)
- [x] Exit code 2로 차단하는 훅 만들어보기 (보호 파일)
- [x] 압축 후 리마인더 훅 (`SessionStart` + `compact` matcher)

**체크포인트**: 파일 수정 → 테스트 자동 실행 → 실패 시 Claude 자동 수정까지 동작

### 2-3. MCP

**읽기**: note.md 섹션 7

**실습**:
- [x] `/mcp` 실행해서 현재 상태 확인
- [x] HTTP MCP 서버 1개 추가해보기 (GitHub, Notion 등 이미 쓰는 서비스)
  ```bash
  claude mcp add --transport http github https://api.githubcopilot.com/mcp/
  ```
- [x] `claude mcp list`로 확인
- [ ] `@github:issue://번호` 형식으로 이슈 직접 참조해서 구현 요청해보기
- [x] `.mcp.json`으로 프로젝트 공유 설정 해보기

**체크포인트**: `@서비스:리소스://ID` 형식으로 외부 데이터를 대화에서 직접 활용

---

## Phase 3: 고급 기능 (Day 8~14)

> 목표: 복잡한 작업을 효율적으로 처리하는 패턴 체득

### 3-1. Subagents

**읽기**: note.md 섹션 5

**실습**:
- [x] 커스텀 에이전트 1개 만들기: `.claude/agents/reviewer.md`
- [ ] `tools`, `model`, `maxTurns` 프론트매터 설정 실험
- [x] 병렬 리뷰 에이전트 3개 만들기 — note.md 실전 예제 참고:
  - `security-reviewer` (opus) — OWASP Top 10 보안 분석
  - `perf-reviewer` (sonnet) — N+1 쿼리/메모리 누수 탐지
  - `test-validator` (haiku) — 테스트 커버리지 검증
- [ ] 포그라운드 vs 백그라운드 실행 차이 체험
- [ ] `memory: user` 설정으로 세션 간 학습 확인

**체크포인트**: "보안/성능/테스트 동시에 리뷰해줘" 한 문장으로 3개 에이전트 병렬 실행

### 3-2. Headless / Agent SDK

**읽기**: note.md 섹션 10

**실습**:
- [ ] `claude -p "간단한 작업" --output-format json` 실행
- [ ] `--allowedTools` 지정해서 자동 승인 실행
- [ ] Unix 파이프 패턴: `cat error.txt | claude -p "원인 분석"`
- [ ] `--continue` / `--resume`으로 세션 이어가기
- [ ] 간단한 셸 스크립트에 Claude 통합

**체크포인트**: 비대화형으로 자동화 파이프라인 1개 구축

### 3-3. Plugins (선택)

**읽기**: note.md 섹션 8

**실습**:
- [ ] 지금까지 만든 skills/agents/hooks를 플러그인으로 패키징
- [ ] `claude --plugin-dir ./my-plugin` 테스트
- [ ] `plugin.json` 매니페스트 작성

**체크포인트**: 다른 프로젝트에서 플러그인 로드해서 동작 확인

---

## Phase 4: 팀/자동화 (Day 15+)

> 목표: 팀 워크플로우에 Claude Code 통합

### 4-1. CI/CD

**읽기**: note.md 섹션 13

**실습**:
- [ ] GitHub Actions: `/install-github-app` 실행
- [x] 기본 워크플로우 `.github/workflows/claude.yml` 배포
- [ ] PR에서 `@claude` 멘션 테스트
- [x] 커스텀 프롬프트로 자동 리뷰 설정

### 4-2. Slack 통합

**읽기**: note.md 섹션 14

**실습**:
- [ ] Claude App 설치 + 계정 연결
- [ ] 라우팅 모드 선택 (Code only vs Code + Chat)
- [ ] 채널에서 `@Claude` 코딩 작업 요청 테스트

### 4-3. Agent Teams (실험)

**읽기**: note.md 섹션 9

**실습**:
- [ ] `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 활성화
- [ ] 간단한 병렬 작업 시도 (예: 보안 리뷰 + 성능 리뷰)

---

## 학습 팁

### 우선순위 매트릭스

```
          높은 빈도
            |
  Phase 1   |   Phase 2
  (기초)     |   (핵심)
            |
───────────┼───────────
            |
  Phase 4   |   Phase 3
  (팀/자동화)|   (고급)
            |
          낮은 빈도
```

- **Phase 1+2가 전체 활용의 80%** — 여기에 집중
- Phase 3은 복잡한 작업이 생길 때 필요한 만큼
- Phase 4는 팀 도입 시점에

### 반복 학습 주기

```
1주차: Phase 1 + 2-1 (Skills)
2주차: Phase 2-2, 2-3 (Hooks, MCP) + Phase 1 복습
3주차: Phase 3 필요한 것만 + Phase 2 복습
4주차~: Phase 4 + 전체 워크플로우 최적화
```

### 학습 기록 방법

각 Phase 완료 후 `note.md`에 개인 메모 추가:
- 실제로 써보니 유용했던 것
- 예상과 달랐던 것
- 내 프로젝트에 맞게 커스터마이즈한 설정

---

## 파일 구조

```
ideanote/
├── note-reference.md   # 공개용 원본 (건드리지 않음)
├── note.md             # 작업용 (메모, 체크, 수정 자유)
└── study-guide.md      # 이 파일 (학습 가이드)
```
