# {{PROJECT_NAME}}

{{PROJECT_CONCEPT}}

## 절대 규칙 (항상)
- 하드코딩 금지: 색·간격·라운드·그림자는 토큰(src/styles/tokens.css)만 — hex·arbitrary 금지.
  bg-{토큰} 지정 시 text-{토큰}-foreground 페어 필수
- Firebase·AI 호출은 features/[기능]/api/ (repository)에서만 — 컴포넌트·훅에서 직접 금지
- UI 텍스트·에러 메시지는 한국어 + 제품 톤·문체 유지 (rules.md § 한국어 카피 체크리스트)
- 완료 전 검증: lint + typecheck + test + build 4종 필수
- 컴포넌트·패키지 우선: UI는 shadcn/ui 카탈로그(`shadcn add`) — 손수 재구현 금지. 패키지는 packages.md
  리치포 맵만, 새 런타임 의존성은 에스컬레이션. 모달·토스트는 공용 래퍼만
- 프로덕션 완결성: 정상·로딩·에러·빈 상태까지 구현해야 완료 — 목업/스텁/TODO/빈 핸들러를 실경로에
  남기지 않기. 부분 구현은 지시 시만 + 미구현 보고 (rules.md § 구현 완결성)
- `any` 남용 금지, `dangerouslySetInnerHTML` 금지 (불가피하면 에스컬레이션 + sanitize)
- 정확한 컴포넌트명·타입명은 파일 직접 Read (기억 금지)

## 제품 톤앤매너
키워드: {{TONE_KEYWORDS}} · 문체: {{SPEECH_LEVEL}} (전 화면·토스트·에러·이메일 통일 — 섞임은 AI 티)

<!-- IF:BRAND_WORLD -->
세계관: {{BRAND_WORLD}}

UI 텍스트·에러 메시지도 세계관 유지.
<!-- END -->

상세: docs/DESIGN.md · rules.md § 톤앤매너 · § 한국어 카피.

## 시작 전 읽을 파일
작업 시작 시 knowledge/INDEX.md 먼저 로드 → 가리키는 상황별 파일만 선택적 로드.

## 프로젝트 파일
- docs/navigator.md(조감·필독) · plan.md(기획) · feature-spec.jsx(스펙) · DESIGN.md(디자인·톤)
- docs/questions.md(요청 로그·append) · insights.md(월간 분석)

## 기술 스택
React 19 + TS(strict) + Vite + TanStack Query v5(서버) + Zustand(클라) + React Router v7 +
react-hook-form/zod + Vitest/RTL
디자인 3종: Tailwind v4 + shadcn/ui + motion(구 framer-motion) — 토큰·프리셋 재사용, 절제된 모션
<!-- IF:FIREBASE_ENABLED -->
백엔드: Firebase v12 모듈러 SDK만 (Auth·Firestore·Storage·Hosting·Functions)
<!-- END -->
<!-- IF:AI_ENABLED -->
AI: 프롬프트는 src/lib/ai/prompts/ 상수로 관리. 키는 클라이언트 노출 금지 — Functions 경유
<!-- END -->

## 아키텍처 (얇은 레이어)
`Page → hooks(TanStack Query/Zustand) → api(repository) → Firebase/AI`
- 서버 상태=TanStack Query만, 클라 상태=Zustand만 — useEffect+fetch 금지
- 역방향 의존·컴포넌트에서 repository 직접 호출 금지. 상세: rules.md § 아키텍처

## Feature 구조
`src/features/[기능]/` = components/ · hooks/(Query 훅) · api/(Firebase·AI 전담) · types.ts ·
index.ts(공개 API — 여기 없는 건 외부 import 금지)

## 모듈 경계 (요약)
- features 간 직접 import 금지 (shared 경유·index.ts 공개 API만)
- docs/: questions.md·insights.md만 · knowledge/: mistakes/recent.md만 에이전트 append
- src/components/ui/·src/styles/ 추가·수정은 에스컬레이션
- firestore.rules·storage.rules: 코드와 같은 커밋으로만 변경 (§ Firebase 보안규칙 대조)
- 상세 표: rules.md § 모듈 경계

## 작업 규모별 절차

- **Small** (1파일·버그·문구): 자기비판 → 검증 1-2개 → 완료
- **Medium** (컴포넌트·훅): INDEX.md 로드 → 자기비판 → 검증 4개
- **Large** (새 feature·Firebase 연동·리팩터): feature-spec.jsx → INDEX.md → 자기비판 → 검증 4개 + 스모크 → questions.md 기록
- **Medium+ 공통 (스코프 잠금)**: 착수 전 "변경 파일 + 안 건드릴 것" 1줄 선언 + 기능 중복 확인.
  선언 밖 파일 수정이 필요해지면 진행 전 보고

## 완료 전 자기비판 (Pre-Submit Critique)

코드 작성 후, 검증 명령어 실행 전에 수행:

1. rules.md § [관련 섹션] 위반 여부 (아키텍처·토큰·모듈 경계·한국어 카피)
2. mistakes/recent.md 같은 카테고리 실수 이력 확인
3. 선언한 범위 밖 파일을 건드렸는가?
4. 위반 → 즉시 수정 / 수정 불가 → 에스컬레이션

상세: knowledge/INDEX.md § 작업 완료 후

## 검증 명령어
`npm run` lint · typecheck · test · build — 4종 전부 통과해야 완료

## 에러 수정 루프
같은 에러 수정 2회 실패 → 중단하고 시도 요약·근본원인·다른 접근 제안 후 사람 확인 (상세: INDEX § 버그/오류)

## 에스컬레이션 (중단하고 보고)
- 스펙 없는 신규 기능 · 새 패키지 추가
<!-- IF:FIREBASE_ENABLED -->
- Firebase 프로젝트 설정·보안규칙 구조 변경
<!-- END -->
- API 키·시크릿·환경변수 (VITE_ = 번들 공개 상기)
- src/components/ui/·src/styles/ 신규 추가 · 아키텍처 원칙 위반해야 풀리는 문제
- UI 명령 모호 (피그마·DESIGN·유사 화면 참조 불가) · 톤앤매너 충돌 기획

## 로그 규칙

### 요청 로깅 (매번)
수행 전 docs/questions.md에 append:
```
## YYYY-MM-DD

### 요청 N
- 내용: 한 줄 요약
- 카테고리: 기능/디자인/리팩터/버그/테스트/배포/메타/기획/AI (택 1+)
- 결과: 완료/부분완료/보류/중단 (작업 후)
- 재작업: ✓(1회 성공) / ↩×N / -(미완료) (작업 후)
- 참조: 관련 실수·함정 파일 경로 (있으면)
- 근본원인: 에이전트가 처음부터 스스로 못 한 이유 (재작업↩ 시 필수·그 외 선택)
- 일반화 후보: 규칙·문서로 만들면 다음엔 이 지시가 불필요해질 한 줄 (있으면만)
```
두 필드는 @session-analyzer가 반복 지시·규칙 후보를 찾는 근거가 된다 — 반복되는 유형이면 채울 것.

### 실수 기록
아래 상황 시 @mistake-logger 호출 → recent.md에 append: 사용자 "아니/다시" 수정 지시 · 같은 에러
2회 반복 · 검증 실패한 채 완료 보고 · 스펙과 다른 구현 · 규칙 위반 지적.
새 플랫폼 함정 발견 시 knowledge/pitfalls.md 추가 **제안** (직접 수정 금지).

## 컨텍스트 관리
컨텍스트 50% 초과 시 `/compact [현재 작업]`.

## 커밋
`<type>(<scope>): <설명>` — feat/fix/refactor/test/docs/style/perf. 한 커밋에 하나만. base: main.

## 배포 설정
- Firebase Hosting 사이트: {{HOSTING_SITE}}
- 프로덕션 도메인: {{PRODUCTION_DOMAIN}}
- 배포 전 `npm run check:web-assets` 통과 필수 (파비콘·앱 아이콘·OG — 누락 시 배포 훅이 막음 → /generate-web-assets)
