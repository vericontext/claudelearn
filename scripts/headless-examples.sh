#!/bin/bash
# =============================================
# Phase 3-2: Headless / Agent SDK 실습 스크립트
# =============================================
# 각 예제를 하나씩 실행해보세요 (전체 실행 X)
# 사용법: 아래 예제를 복사해서 터미널에 붙여넣기

# -------------------------------------------
# 실습 1: 기본 headless + JSON 출력
# -------------------------------------------

# 텍스트 출력 (기본)
claude -p "이 프로젝트의 파일 구조를 설명해줘" --output-format text

# JSON 출력 (메타데이터 포함)
claude -p "이 프로젝트의 파일 구조를 설명해줘" --output-format json

# JSON에서 결과만 추출
claude -p "이 프로젝트의 파일 구조를 설명해줘" --output-format json | jq -r '.result'

# -------------------------------------------
# 실습 2: --allowedTools 자동 승인
# -------------------------------------------

# 읽기 도구만 허용 (승인 프롬프트 없이 실행)
claude -p "note.md에서 MCP 섹션을 찾아서 요약해줘" \
  --allowedTools "Read,Grep,Glob"

# git 명령 자동 승인
claude -p "최근 커밋 5개를 분석하고 패턴을 설명해줘" \
  --allowedTools "Bash(git log *),Bash(git diff *),Read"

# -------------------------------------------
# 실습 3: Unix 파이프 패턴
# -------------------------------------------

# git diff를 Claude에게 분석 요청
git log --oneline -5 | claude -p "이 커밋 히스토리를 분석하고 프로젝트 진행 상황을 설명해줘"

# 파일 내용을 파이프로 전달
cat study-guide.md | claude -p "이 학습 가이드에서 아직 완료하지 않은 항목을 정리해줘"

# -------------------------------------------
# 실습 4: 세션 이어가기
# -------------------------------------------

# 첫 번째 요청
claude -p "note.md의 Skills 섹션을 분석해줘" --output-format text

# 이전 세션 이어서 (--continue)
claude -p "방금 분석한 내용 중 가장 중요한 3가지를 정리해줘" --continue

# 특정 세션 재개 (session_id 저장 후 사용)
# session_id=$(claude -p "프로젝트 분석 시작" --output-format json | jq -r '.session_id')
# claude -p "분석 계속해줘" --resume "$session_id"

# -------------------------------------------
# 실습 5: 실용 스크립트 — 노트 섹션 요약기
# -------------------------------------------

# 아래 함수를 .zshrc나 .bashrc에 추가하면 편리합니다
# 사용법: note-summary hooks
note_summary() {
  local topic="${1:?Usage: note_summary <topic>}"
  grep -A 100 "## .*${topic}" note.md | head -50 | \
    claude -p "이 내용을 3줄로 요약해줘. 한국어로." --output-format text
}
