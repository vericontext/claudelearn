# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# claudelearn

이 프로젝트는 Claude Code 기능 학습용 노트 저장소입니다.

## 파일 역할

- `note-reference.md` — 공개용 원본. **절대 수정 금지**
- `note.md` — 개인 작업용 노트. 자유롭게 수정 가능
- `study-guide.md` — 단계별 학습 가이드 (체크리스트 포함)

## 사용 가능한 스킬

| 스킬 | 설명 |
|------|------|
| `/summarize` | note.md 특정 섹션 1분 요약 |
| `/review-note` | note.md 섹션 리뷰 및 개선 제안 |
| `/check-progress` | study-guide.md 학습 진행률 체크 |
| `/project-status` | git 상태 + 파일 구조 요약 |

## 활성 에이전트

- `note-reviewer` — note.md 품질 검증
- `note-updater` — note.md 섹션 업데이트
- `quick-search` — 노트 키워드 검색
- `study-coach` — 학습 진행 코칭

## 규칙

- 모든 문서는 한국어로 작성
- 커밋 메시지는 영어로 작성
- `note-reference.md` 편집 시 PreToolUse 훅이 자동 차단
