---
name: review-note
description: note.md의 특정 섹션을 리뷰하고 개선점을 제안하는 스킬. 노트 품질 점검 시 사용.
argument-hint: [섹션번호 또는 기능명]
allowed-tools: Read, Grep, Glob
---

## 지시사항

note.md에서 `$ARGUMENTS`에 해당하는 섹션을 찾아 리뷰하세요.

리뷰 기준:
1. **정확성**: 공식 문서(note-reference.md)와 비교하여 누락/오류 확인
2. **실용성**: 실제 사용 시 바로 참고할 수 있는 수준인지
3. **간결성**: 불필요한 중복이나 장황한 설명이 없는지

결과를 다음 형식으로 출력:
- 점수: /10
- 잘한 점: (간단히)
- 개선 제안: (구체적으로)
