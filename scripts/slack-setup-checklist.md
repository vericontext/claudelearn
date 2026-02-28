# Slack 통합 설정 체크리스트

## 전제 조건
- [ ] Claude Pro/Max/Teams/Enterprise 플랜 (Claude Code 접근 포함)
- [ ] [claude.ai/code](https://claude.ai/code) 접근 활성화
- [ ] GitHub 계정이 Claude Code 웹에 연결됨

## 설정 순서

### 1. Slack App 설치
- [ ] 워크스페이스 관리자가 [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)에서 설치

### 2. Claude 계정 연결
- [ ] Slack → Apps → Claude → App Home → "Connect" 클릭

### 3. Claude Code 웹 설정
- [ ] [claude.ai/code](https://claude.ai/code) 접속
- [ ] GitHub 계정 연결
- [ ] 레포 인증 (claudelearn 포함)

### 4. 라우팅 모드 선택
- [ ] App Home에서 선택:
  - **Code only**: 모든 @Claude → Claude Code 세션
  - **Code + Chat**: 코딩은 Code로, 일반 질문은 Chat으로 자동 라우팅

### 5. 채널에 추가
- [ ] `/invite @Claude` 실행 (원하는 채널에서)

## 테스트
- [ ] `@Claude 이 레포의 study-guide.md를 분석하고 진행률을 알려줘`
- [ ] 결과: View Session / Create PR 버튼 확인
