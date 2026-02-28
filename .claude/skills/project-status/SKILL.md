---
name: project-status
description: 프로젝트의 현재 git 상태와 파일 구조를 요약하는 스킬
---

## 프로젝트 현황 리포트

아래 동적 컨텍스트를 기반으로 프로젝트 현황을 한국어로 요약하세요.

### Git 상태
!`git status --short`

### 최근 커밋
!`git log --oneline -5`

### 파일 구조
!`find . -not -path './.git/*' -type f | head -20`

위 정보를 바탕으로:
1. 현재 브랜치와 커밋 상태
2. 변경/추가된 파일 요약
3. 다음 할 일 제안
