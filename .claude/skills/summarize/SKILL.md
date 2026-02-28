---
name: summarize
description: note.md의 특정 기능을 1분 요약으로 압축하는 스킬. 빠른 복습용.
argument-hint: [기능명 - 예: hooks, mcp, skills]
allowed-tools: Read, Grep
---

## 지시사항

note.md에서 `$ARGUMENTS` 기능에 대한 섹션을 찾아 **1분 안에 읽을 수 있는 요약**을 만드세요.

형식:
```
## $ARGUMENTS 1분 요약

**한줄 정의**: ...
**핵심 3가지**:
1. ...
2. ...
3. ...
**가장 자주 쓸 패턴**: (코드 예시 1개)
**주의할 점**: (1줄)
```
