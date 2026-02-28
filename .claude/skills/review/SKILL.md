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
