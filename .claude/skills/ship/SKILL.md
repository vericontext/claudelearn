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
