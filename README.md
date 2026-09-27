# React + Firebase + Claude Code 루프 엔지니어링 시스템

> **React + Firebase + Claude Code 조합의 웹개발 외주·유지보수에 특화된 하네스.**
> 프로젝트를 반복하며 나온 실수·지시·프로덕션 에러를 관찰해 규칙으로 승격하고, 다음 프로젝트에 그대로
> 이식합니다. 쓸수록 사람이 지시(steering)할 일이 줄어드는 것이 목표입니다.
> 서브에이전트·스킬·CLAUDE.md 등 Claude Code 네이티브 기능으로 구현되어 있어 **Claude Code를 전제**로
> 합니다. Flutter 앱 프로젝트용은 별도 키트(fine-harness-flutter-kit)로 제공됩니다.
>
> 이 키트는 구매 고객 전용이며 사용 조건은 [`LICENSE`](LICENSE)를 따릅니다 (재배포·재판매 금지).

## 설치 — 아래 블록을 새 프로젝트의 Claude Code에 그대로 붙여넣기

사람이 할 일은 이 한 번의 붙여넣기와, 설치 중 에이전트가 묻는 질문(프로젝트명·톤·Firebase 사용
여부 등)에 답하는 것뿐입니다. 나머지는 전부 자동으로 진행됩니다.

```
React + Firebase + Claude Code 루프 엔지니어링 시스템 설치:

1. git clone --depth 1 https://github.com/FineHourTeam/fine-harness-react-kit.git /tmp/rcs
2. /tmp/rcs/bootstrap.md 를 읽고 Step 0부터 순서대로 정확히 실행 (질문은 나에게 한 번에 하나씩)
   — GitHub CLI(gh)·Firebase CLI·Google Cloud CLI(gcloud) 로그인, Firebase 프로젝트/웹앱/Hosting
     생성, .env 구성, Firebase MCP(.mcp.json) 등록, 디자인 토큰(tokens.css)까지 이 단계에서 전부
     설정된다. 건너뛴 항목은 docs/setup-checklist.md에 남길 것.
3. 설치 완료 보고 후 /tmp/rcs 삭제
4. docs/setup-checklist.md의 "⚡ Day 0" 미완료 항목을 하나씩 브리핑해줘 (왜 지금 해야 하는지 +
   어디서 어떻게 하는지). 내가 완료 확인한 것만 체크 표시.
5. 설치 검증: "knowledge/INDEX.md 읽고 네가 뭘 해야 하는지 요약해봐"를 스스로 실행해 결과를 보여줘
```

설치가 끝나면: 개발팀 Loop(서브에이전트 6종 + UI 규칙 훅)는 즉시 활성, Ops Loop(Sentry AutoFix)·웹
에셋 생성 등 설치형 스킬은 파일만 깔린 상태로 대기하다가 필요할 때 `/스킬명`으로 활성화합니다.
에이전트의 한국어 문장 품질(fluent-korean output-style)은 새 세션부터, 스타터킷 새 버전 알림은 세션
시작 훅이 담당합니다. 연동 현황은 `docs/setup-checklist.md`에서 확인.

**그 외 시작점**

| 하려는 일 | 여기로 |
|----------|--------|
| Firebase 콘솔·IAM·도메인·SEO 등 사람 개입 세팅 | `docs/REACT_FIREBASE_SETUP.md` (설치 전후 체크리스트) |
| 이미 설치한 프로젝트에 새 버전 반영 | 세션 시작 시 🆕 알림 → `/update-starter` (수동 절차는 `CHANGELOG.md` 업그레이드 가이드) |
| 설치·업데이트가 막혔을 때 | [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) (증상별 해결법) |
| 사용 조건 확인 | [`LICENSE`](LICENSE) |

> **AI 에이전트가 이 문서를 직접 읽고 있다면**: 위 설치 블록을 받았다면 그대로 순서대로 실행하세요.
> 이 README가 메인 진입점이고, 코드펜스(` ``` `) 안은 그대로 수행할 지시문이며 `[대괄호]`만 실제
> 프로젝트 정보로 교체합니다. 상세 내용은 `docs/` 하위 문서를 찾아 읽으세요.

---

## 컨텍스트 비용 — 설치하면 얼마나 읽히나

설정이 많을수록 에이전트가 매번 읽어야 할 글이 늘어 작업 공간이 줄어듭니다. 이 키트는 **항상 읽히는 부분을 작게
두고, 규칙·함정 문서는 상황에 맞는 것만 골라 읽도록** 설계했습니다. v2.0 기준 글자 수:

| 언제 읽히나 | 무엇 | 글자 수 |
|------------|------|---------|
| 항상 | `CLAUDE.md` (104줄) | 약 4,000자 |
| 항상 | 한국어 문장 품질 output-style | 약 3,000자 |
| 항상 | 서브에이전트 6종·스킬 7종 설명 | 약 1,200자 |
| 작업 시작 시 | `knowledge/INDEX.md` (상황별 라우터) | 약 4,600자 |
| 필요할 때만 | `rules.md`·`pitfalls.md`·`unknown-unknowns.md` | 약 35,000자 중 해당 섹션만 |

항상·시작 시 합계는 약 1만 2천 자입니다. 토큰으로는 대략 같은 자릿수(수천~1만여 토큰)로, 20만 토큰 작업 공간의 몇 %
수준입니다. 토큰 수는 글자 수에서 어림한 값이며 모델·언어 비율에 따라 달라집니다. 서브에이전트·스킬 본문은 호출될 때만
읽힙니다. 훅은 에이전트가 읽는 글이 아니라서 컨텍스트를 쓰지 않고, 규칙을 어겼을 때만 짧은 메시지를 돌려줍니다.

### 비용 줄이기 (선택 — 개인 설정)

키트는 모델을 강제하지 않습니다. 비용이 부담되면 아래를 **개인 설정**(`~/.claude/settings.json`)에서 고르세요.

- **평소엔 Sonnet, 어려운 설계·디버깅만 Opus**: `"model": "sonnet"`으로 두고 필요할 때 `/model opus`.
- **관련 없는 작업 사이엔 `/clear`**: 이전 작업 대화가 남아 있으면 이후 모든 요청에 그 비용이 붙습니다.
- **MCP는 필요한 것만**: MCP 서버마다 도구 설명이 작업 공간을 차지합니다. Firebase MCP도 설치 때 쓰는 제품만 켭니다(`--only`).
- 키트의 서브에이전트는 이미 역할별로 모델을 정해 두었습니다 — 형식대로 한 줄 적는 실수 기록은 Haiku, 판단이 필요한 분석·제안은
  Sonnet. 모든 서브에이전트를 한꺼번에 Haiku로 바꾸는 전역 설정(`CLAUDE_CODE_SUBAGENT_MODEL`)은 판단 에이전트까지 약해지므로
  권하지 않습니다.

무료 설정 모음(superpowers·gstack 등)과 함께 써도 됩니다. 이 키트가 맡는 영역은 **React + Firebase 프로젝트의 규칙·검증
게이트·실수 학습 루프·버전 업데이트**이고, 범용 작업 방식 도구와는 역할이 겹치지 않게 골라 쓰면 됩니다.

---

## 기술 스택 (2026-07 프로덕션 리서치 기반)

"안정·단순 우선" 원칙 — 코드젠·신생 도구는 기본값에서 제외하고 에스컬레이션 대상으로 분류.

| 영역 | 표준 | 비고 |
|------|------|------|
| UI/빌드 | React 19 + TypeScript(strict+) + Vite | tsconfig에 noUncheckedIndexedAccess 등 강화 플래그 |
| 서버 상태 | TanStack Query v5 | useEffect+fetch 조합 금지 |
| 클라이언트 상태 | Zustand v5 | 로컬은 useState 1순위 |
| 라우팅 | React Router v7 | TanStack Router는 에스컬레이션 옵션 |
| 폼 | react-hook-form + zod v4 | 스키마 = 검증 + 타입 단일 출처 |
| 스타일 | **Tailwind CSS v4 + shadcn/ui + motion**(구 framer-motion, 3종 기본 조합) | tokens.css(OKLCH CSS 변수)·motion.ts 프리셋이 단일 출처, 다크모드 필수, 절제된 모션 |
| 컴포넌트·패키지 | **shadcn/ui(Radix) 조합 우선** + 리치포 맵(knowledge/packages.md) | 손수 재구현 금지, 검증된 표준만, 새 런타임 의존성은 4단계 채택 정책 |
| 아이콘 | 프로젝트 SVG 세트 (`src/components/icons`, 컨셉에 맞게 새로 그림) | lucide 등 기본 아이콘 팩 금지 — "AI가 만든 기본 화면" 인상 제거 |
| SEO/에셋 | React 19 네이티브 metadata(`<Seo>`) + robots.txt + generate-web-assets(파비콘·OG·PWA) | react-helmet 불필요, 라우트별 title/description·인증뒤 noindex |
| 백엔드 | Firebase v12 모듈러 SDK | Auth/Firestore/Storage/Hosting/Functions, 에뮬레이터 기본 |
| 모니터링 | Sentry | **웹은 Crashlytics 미지원** — Ops Loop 감지 소스 |
| 테스트 | Vitest + RTL + Playwright | 70/20/10 + Firestore rules 단위 테스트 |
| 린트 | ESLint 9 flat + typescript-eslint(strictTypeChecked) + Prettier | jsx-a11y·react-hooks(컴파일러 규칙) 포함 |
| i18n | react-i18next + typed resources | 한국어 기본, 확장 대비 |
| 성능 예산 | 초기 JS(gzip) ≤ 250KB, LCP<2.5s / INP<200ms / CLS<0.1 | rules.md § 빌드/배포 |

상세 근거·전체 규칙: `template/knowledge/rules.md`(초기 규칙),
`template/knowledge/unknown-unknowns.md`(사전 예방 함정 58선).

---

## 루프 엔지니어링 시스템

모든 루프는 같은 4단계를 돕니다 — **관찰 → 기록 → 증류 → 재적용**. 차이는 **"무엇을 관찰해서 어디에
재적용하는가"의 범위**뿐이며, 이 범위 기준으로 시스템 전체가 겹침 없이 세 루프로 나뉩니다:

| | 1️⃣ 개발팀 Loop | 2️⃣ Ops Loop | 3️⃣ 메타 Loop |
|---|---|---|---|
| **관찰 대상** | 세션 **안** — 코딩 중의 실수·지시 | 세션 **밖** — 프로덕션 에러·CI 실패·이슈·성능 회귀 | 프로젝트 **간** — 각 프로젝트가 쌓은 지식 |
| **재적용 대상** | 그 프로젝트의 `knowledge/` 규칙 | 그 프로젝트의 코드 (수정 PR) | 스타터킷 기본값 (다음 설치부터 전 프로젝트 적용) |
| **형태** | 서브에이전트 6종 + UI 규칙 훅 | 설치형 스킬 (`.claude/skills/`) | 키트 제작사가 운영 → 새 버전으로 전달 |
| **범위** | 프로젝트 1개 | 프로젝트 1개 | 여러 프로젝트 → 이 키트 |

**세 루프가 공유하는 원칙 두 가지**

1. **트리거는 Push 아니면 Pull.** 사건이 나는 순간 즉시 반응하거나(Push), 쌓인 상태를 주기적으로
   훑는다(Pull).
2. **사람 승인 없이는 아무것도 정식 반영되지 않는다.** 규칙 승격도, 코드 머지도, 스타터킷 반영도
   자동화는 항상 제안(proposal·PR)까지만이고 확정은 사람이 합니다.


### 1️⃣ 개발팀 Loop — 세션 안의 실수를 프로젝트 지식으로

`bootstrap.md`로 항상 설치되는 서브에이전트 6종 + 결정론적 훅 3종(편집 즉시 UI 규칙 검사 · 끝내기 전 검증 · 배포 직전 웹 에셋 검사).

**Push형 — 사건 발생 즉시**

<details>
<summary><strong>@mistake-logger</strong> — 실수 자동 기록 (실수 발생 즉시)</summary>

사용자가 "아니/다시" 등으로 수정 지시, 같은 에러 2회 이상 반복, 검증 명령어 실패한 채 완료 보고,
디자인 토큰 미사용 등을 감지하면 `knowledge/mistakes/recent.md`에 카테고리·원인·해결을 한 건씩 append.
메인 세션과 별도 컨텍스트에서 동작해 결과 요약 한 줄만 반환한다.
</details>

<details>
<summary><strong>check-ui-rules.sh 훅</strong> — 편집 즉시 결정론적 차단</summary>

PostToolUse(Edit|Write) 훅이 하드코딩 색상(Tailwind arbitrary hex·inline style)·빈 콜백 버튼·
alert/confirm 직접 호출·12px 미만 폰트·dangerouslySetInnerHTML·features 간 직접 import·간격/라운드/
섀도우 arbitrary value(`p-[13px]` 등)·**기본 아이콘 팩(lucide 등)과 화면 코드의 인라인 `<svg>`**·영역 배경의 `bg-muted`를
편집 즉시 exit 2로 차단해 에이전트에게 피드백한다. 텍스트
규칙(CLAUDE.md)의 결정론적 백스톱.
</details>

<details>
<summary><strong>check-done.sh 훅</strong> — 끝내기 전 검증 자동 실행 · ✅ 구현됨</summary>

Stop 훅이 에이전트가 작업을 끝내려는 순간 `src/`가 바뀌었으면 typecheck·lint·test를 직접 돌리고, 실패하면 오류 요약과 함께
되돌려 보낸다(exit 2). 문서에만 적힌 "완료 전 검증 필수"는 에이전트가 자주 건너뛴다는 관찰에 따른 결정론적 게이트다.
질문·문서 작업(`src/` 변경 없음)과 이미 통과한 상태는 다시 돌리지 않고, 한 번 되돌린 뒤에는 무한 반복을 막으려고 통과시킨다
(그래도 실패가 남으면 에이전트가 완료 보고에 그대로 적는다). build는 느려서 CI와 배포 전 검사가 맡는다.
</details>

<details>
<summary><strong>check-deploy-web-assets.sh 훅</strong> — 배포 직전 파비콘·OG 누락 차단 · ✅ 구현됨</summary>

PreToolUse(Bash) 훅이 `firebase deploy`(호스팅 포함)·`hosting:channel:deploy`·`npm run deploy` 직전에
`scripts/check-web-assets.mjs --strict`를 돌려, 파비콘·앱 아이콘·매니페스트·OG 이미지·robots.txt 크롤 허용 중
하나라도 빠지면 배포를 막고 `/generate-web-assets`로 보낸다. Google 검색 결과 아이콘 기준(원본 HTML의
`rel="icon"`, 48px보다 큰 ICO/PNG — SVG 미지원, Googlebot 크롤 허용)을 그대로 검사한다. 같은 검사가 `npm run build`
전(prebuild, 경고만)과 배포 CI(엄격)에서도 돌고, 배포 후엔 `--url`로 실제 사이트를 Googlebot처럼 확인한다.
</details>

**Pull형 — 쌓인 로그를 주기적으로 증류**

<details>
<summary><strong>@rule-promoter</strong> — 규칙 승격 제안 (주 1회)</summary>

recent.md에서 **3회 이상 반복**된 실수 패턴만 추려 `docs/proposals.md`에 규칙 승격안을 작성한다.
기존 규칙과의 충돌 여부도 함께 표시. rules.md는 직접 수정하지 않으며, 사람이 승인해야 반영된다.
</details>

<details>
<summary><strong>@rule-deprecator</strong> — 규칙 유효성 감사 (규칙 20개 초과 또는 트리거 시)</summary>

오래되거나 안 지켜지는 규칙이 쌓이면, 각 규칙을 승격(CLAUDE.md 이동)·유지·강화·삭제·충돌 5가지로
분류한 감사 보고서를 작성한다. 규칙이 무한정 쌓여 신호 대비 잡음이 커지는 것(context rot)을 막는 장치.
</details>

<details>
<summary><strong>@mistake-compressor</strong> — 로그 압축 (recent.md 200줄 초과 시)</summary>

recent.md가 200줄을 넘으면 3개월 이상 지난 항목을 분기별 아카이브로 카테고리 요약만 남기고
이동시킨다. 정보 손실 없이 컨텍스트 비용만 절감한다.
</details>

<details>
<summary><strong>@session-analyzer</strong> — 시스템 전체 분석 (월 1회 또는 50건 누적 시)</summary>

`docs/questions.md`를 분석해 재작업(↩) 비율, 규칙별 효과성 점수, INDEX.md 라우팅 개선안을
`docs/insights.md`에 기록한다. 필요하면 `@rule-deprecator`·`@agent-synthesizer` 호출을 권고한다.
</details>

<details>
<summary><strong>@agent-synthesizer</strong> — 신규 에이전트 초안 제안 (session-analyzer 트리거 시)</summary>

기존 6개 에이전트로 처리되지 않는 반복 패턴을 발견하면 새 서브에이전트 초안을 제시한다. 최대 8개
한도(`GOVERNANCE.md`)이며, 사람 승인 없이는 등록되지 않는다 — 루프가 스스로 무한정 증식하는 것을
막는 하드 캡.
</details>

### 2️⃣ Ops Loop — 세션 밖의 사건을 수정 PR로

`bootstrap.md`는 아래 모듈들의 **스킬 파일만 설치**합니다(자동 활성화 아님). 실제로 필요해지면
`/스킬명`으로 직접 실행하고, 그 스킬이 시크릿 등록·외부 서비스 연동을 사람 승인을 받아가며 안내합니다.

**Push형 — 외부 시스템이 이벤트를 알려줌**

<details>
<summary><strong>/setup-sentry-autofix</strong> — Sentry 에러 자동 수정 · ✅ 구현됨</summary>

프로덕션에서 신규 에러(Sentry)가 발생하면 웹훅(HMAC 서명 검증) → Cloud Function이 GitHub Actions를
자동 트리거하고, Claude가 원인을 분석·수정한 뒤 **lint/typecheck/test 기계 게이트 + 별도 Claude
리뷰 게이트**를 모두 통과해야만 PR을 생성한다. 웹은 Crashlytics가 없어 Sentry가 감지 소스다.
구성 파일: `templates/firebase/sentry-to-github-function.js`, `templates/ci/sentry-autofix.yml`.
</details>

**Pull형 — 우리가 주기적으로 확인하러 감**

<details>
<summary><strong>/setup-auto-triage</strong> — GitHub 이슈 · CI 실패 다이제스트 · ✅ 구현됨</summary>

평일 아침마다 미처리 이슈 + 최근 CI 실패를 함께 스캔해, Claude가 P0/P1/P2로 분류하고
knowledge/ 이력과 대조(재발 표시)한 뒤 고정 다이제스트 이슈 1개를 갱신한다. 보고만 하고 코드는
건드리지 않는다. 구성 파일: `templates/ci/auto-triage.yml`.
</details>

<details>
<summary><strong>/setup-perf-monitor</strong> — Core Web Vitals · 번들 예산 · ✅ 구현됨</summary>

주 1회 프로덕션 URL을 Lighthouse로 측정(모바일 3회 중앙값), `lighthouserc.json` 성능 예산 위반 시
이슈 생성/갱신. 스토어 리뷰 모니터링의 웹 대응물 — 웹은 별점 대신 웹바이탈이 사용자 불만의 선행
지표다. 구성 파일: `templates/ci/perf-monitor.yml`, `templates/react/lighthouserc.example.json`.
</details>

> **새 Ops Loop 모듈 추가법**: "감지 로직 + 워크플로우 + 설치 스킬" 3종 세트로 만들고, 외부 서비스가
> webhook을 지원하면 Push·아니면 Pull로 분류한 뒤 프로젝트의 `docs/setup-checklist.md`에 함께 기록.

### 3️⃣ 메타 Loop — 키트 자체가 좋아지는 루프

> 1️⃣·2️⃣는 **프로젝트**를 개선하지만, 이 루프는 **키트 자체**를 개선합니다.
> 키트 제작사가 여러 프로젝트에서 반복 확인된 실수·규칙만 골라 일반화하고, 검토를 거쳐 새 버전에
> 담습니다. 고객 프로젝트의 코드나 기록을 수집하지 않으며, 고객 쪽에서 할 일은 세션 시작 때 🆕 알림이
> 뜨면 `/update-starter`로 반영하는 것뿐입니다.

---

## 지원 도구 (루프 아님)

<details>
<summary><strong>/setup-firebase-mcp</strong> — Firebase 라이브 조회 등록 · ✅ 구현됨</summary>

공식 Firebase MCP 서버(`firebase-tools mcp`, GA)를 `.mcp.json`에 등록해 에이전트가 Firestore
데이터·보안규칙·Auth·Functions 로그를 직접 조회하게 한다. 시크릿·PAT 발급이 필요 없어 가볍다.
</details>

<details>
<summary><strong>/frontend-design</strong> — 랜딩·소개 페이지의 시각 방향 · ✅ 구현됨</summary>

Anthropic 공개 스킬 `frontend-design`(Apache-2.0)의 한국어 수정본. 랜딩·서비스 소개·첫 화면처럼 "이 서비스만의 인상"이
필요한 화면에서 쓴다. 흔한 AI 기본값(크림 배경+세리프, 똑같은 둥근 카드, 영문 대문자 라벨, 버튼 끝 `→` 등)을 피하도록
브리프 초안 → 기본값 점검 → 사람 승인 → 구현 → 자기 비판 순서로 진행한다. 원본과 달리 **이 키트의 규칙이 우선**한다 —
색은 `tokens.css` 용도 토큰으로만, 본문 서체는 Pretendard 유지(제목 서체는 한글 지원 서체만 승인 후 추가), 모션은 `motion` 프리셋.
이미 디자인이 정해진 일반 기능 화면에는 쓰지 않는다.
</details>

<details>
<summary><strong>/generate-web-assets</strong> — 웹 에셋 미리 생성 · ✅ 구현됨</summary>

로고 원본을 `web-assets/logo-source/`에 넣어두면 파비콘 세트·PWA 아이콘·OG 이미지(1200×630)·
manifest를 생성하고 index.html 메타에 연결한다. 아이콘은 ImageMagick, OG는 HTML/CSS 템플릿을
Playwright로 렌더링 — 스토어 에셋의 웹 대응물. 배포 전 검사가 실패하면 에이전트가 이 스킬로 보내진다.
</details>

<details>
<summary><strong>/update-starter</strong> + 세션 시작 버전 알림 훅 — 새 버전 반영 · ✅ 구현됨</summary>

설치본은 `.claude/starter-version`을 갖고, `hooks/check-starter-version.sh`(SessionStart, 하루 1회 캐시)가
원격 `VERSION`과 비교해 새 버전이 있으면 🆕 알림을 띄운다. 에이전트가 "지금 업데이트할까요?"를 묻고,
수락하면 `/update-starter`가 CHANGELOG의 해당 버전 항목("달라진 것 / 새로 써볼 수 있는 것 / 업그레이드 시
할 일")을 먼저 보여준 뒤 파일별 정책(교체·신규만 추가·수동 병합·보존)대로 반영하고, 완료 보고에 버전별
변경 내역 링크와 새로 써볼 수 있는 기능을 붙인다.
</details>

<details>
<summary><strong>한국어 품질 3층</strong> — fluent-korean output-style + rules § 한국어 카피(+훅) + im-not-ai 연계 · ✅ 구현됨</summary>

① **에이전트가 말하는 한국어**: [fluent-korean](https://github.com/snflkd/fluent-korean) output-style(MIT)
사본을 `.claude/output-styles/`에 설치하고 settings.json `outputStyle` 기본값으로 켠다 — 조사·어미 생략,
명사 나열, 비유어 치환 같은 "기계 한국어"를 시스템 프롬프트 층위에서 막는다.
② **제품 안의 한국어(UI·알림·이메일·마케팅)**: `knowledge/rules.md § 한국어 카피` — 2026-09 웹 리서치(토스·당근
SEED·배민·구름 라이팅 가이드, KatFish ACL 2025)로 정리한 서비스 특화 AI 티 블랙리스트: 문체(해요/합쇼) 혼용,
과잉 경어, "성공적으로"류 직역 완료문, 영어 CTA 문법, 변수 뒤 조사 하드코딩, 영어식 숫자·날짜, 이모지·느낌표
남발 등. 5종은 `check-ui-rules.sh` 검사 9가 편집 즉시 차단.
③ **300자+ 산문 카피**(랜딩·온보딩·이메일·공지): 사용자 전역 도구 [im-not-ai](https://github.com/epoko77-ai/im-not-ai)의
`/humanize-scan`으로 AI 티를 점검하도록 INDEX 작업 완료 절차에 연결 (설치는 bootstrap K단계가 안내, 프로젝트 파일 아님).
</details>

<details>
<summary><strong>templates/react/ 베이스 코드</strong> — ✅ 구현됨</summary>

tokens.css(디자인 토큰 단일 출처)·firebase/env/query-client/sentry/i18n 단일 지점·인증 가드
(protected-route)·설정 example(tsconfig strict+/ESLint 9 flat/vite/prettier/index.html)·CI 5종(react-ci · hosting 배포 · sentry-autofix · auto-triage · perf-monitor).
"브랜드 색 변경" 같은 요청이 토큰 파일 한 곳 수정으로 끝나는 구조.
</details>

<details>
<summary><strong>docs/setup-checklist.md</strong> — 연동 현황 체크리스트 · ✅ 구현됨</summary>

이 프로젝트에 어떤 CLI·MCP·API 키·Ops Loop 모듈·웹 에셋이 실제로 연동/설치됐는지 체크박스로 관리한다.
</details>

---

## 근거 자료와 반영 내역 (v2.0)

v2.0은 하네스 평가·설계에 관한 공개 자료를 조사해 **뺄 것은 빼고 보강할 것은 보강**했습니다. 자료가 다른 도구·벤치마크에서
나온 경우가 많아, 이 키트에 맞게 옮긴 부분은 추론이 섞여 있습니다. 그래서 반영한 것마다 키트 개선 전후를 같은 작업으로 비교해
확인하는 방식을 유지합니다.

| 출처 | 핵심 내용 | 키트에 반영한 것 |
|------|----------|----------------|
| 팀 디자인 원칙 (FDS) | 아이콘은 제품 컨셉에 맞게 새로 그린다 · 배경은 흰색, 회색은 #f9f9f9 하나 | **프로젝트 SVG 아이콘 세트**(`src/components/icons/` — 설치 때 컨셉으로 스타일을 정하고 기본 13종을 그림, 기본 아이콘 팩은 훅·lint·끝내기 전 검사가 차단) · **`bg-background-subtle`(#f9f9f9)** 토큰과 영역 배경 규칙 |
| Anthropic, "Demystifying evals for AI agents" (2026-01) | 에이전트가 한 말이 아니라 결과로 채점 · pass^k(모든 시도 성공) · 회귀와 새 능력을 나눠서 잰다 | 키트를 고칠 때마다 같은 작업을 키트 있음·없음으로 반복 실행해, 실제로 동작하는지를 기준으로 비교한다 (규칙을 만들 때 쓰지 않은 작업도 포함) |
| Claude Code 문서, 플러그인 eval · 스킬 | 스킬 설명은 목록 예산(작업 공간의 1%, 설명당 1,536자)을 쓴다 | 스킬·서브에이전트 설명 길이 점검 — 새 스킬 설명도 예산 안(위 컨텍스트 비용 표) |
| Böckeler, "Harness engineering for coding agent users" 외 (martinfowler.com, 2026) | 가이드(사전 지시)와 센서(사후 검사)를 함께 · 문서에만 적힌 검증 지시는 자주 건너뜀 · 에이전트가 읽는 오류 메시지에 고치는 법을 · 늘 통과하는 센서는 정리 대상 | **Stop 훅 `check-done.sh`** 로 끝내기 전 검증을 결정론적으로 · 규칙 승격은 훅·lint·테스트를 먼저 고르고 산문은 마지막 |
| Vats·Golev, "The Scaffold Effect" (arXiv 2607.22585) | 하네스를 바꾸면 성공률은 0~8%p 움직이지만 해결 1건당 토큰은 최대 약 40배 차이 | 비교할 때 성공률과 함께 해결 1건당 비용을 본다 · 질문에 답만 하는 요청은 요청 로그를 생략해 비용을 줄였다 |
| Lin 외, "Agentic Harness Engineering" (arXiv 2604.25850) | 효과는 도구·미들웨어·메모리 쪽에서, 시스템 프롬프트만 바꾸면 오히려 하락 · 변경이 무엇을 깨뜨릴지는 예측이 거의 안 됨 → 예측을 적고 다음 평가로 확인·되돌림 | `@rule-promoter` 제안에 **강제 수단 서열**(훅 → lint → 테스트 → 설치 → 산문)과 "막을 것·깨뜨릴 위험·확인 방법" · `@rule-deprecator`에 **되돌림 후보** |
| Gloaguen 외, "Evaluating AGENTS.md" (arXiv 2602.11988) · OpenAI, "Harness engineering" (2026-02) | 저장소 개요·중복 설명이 담긴 컨텍스트 파일은 성공률을 못 올리고 비용만 20% 넘게 늘림 · 짧은 목차형 문서 + 주기적 정리 | CLAUDE.md 131줄 → 104줄(기술 스택 목록·실행할 수 없는 지시 제거) · **안 어기는 규칙을 CLAUDE.md로 올리던 기준 폐지** → 삭제·산문 축약 후보로 |
| Anthropic `frontend-design` 스킬 (Apache-2.0) | 흔한 AI 디자인 기본값 목록 · 계획 → 기본값 점검 → 구현 → 자기 비판 | **`/frontend-design` 한국어 수정본** — 키트의 토큰·폰트·모션 규칙이 우선 |
| Karpathy 코딩 지침 (multica-ai/andrej-karpathy-skills, MIT) | 필요한 곳만 고침 · 요청 안 한 추상화 금지 · 검증 가능한 성공 기준 | CLAUDE.md § 작업 방식: 주변 코드·서식 손대지 않기(포매터는 바꾼 파일만) · 한 번 쓰는 코드에 추상화 금지 · 버그는 재현 테스트 먼저 · 가정은 완료 보고에. **"모호하면 멈추고 물어라"는 뺐다** — 이 키트 평가에서 과잉 에스컬레이션이 가장 큰 실패 원인이었다 |
| everything-claude-code 토큰 최적화 가이드 | 평소 Sonnet · 서브에이전트는 싼 모델 · `/clear`·MCP 절제 | 서브에이전트별 모델 지정(기록은 Haiku, 분석은 Sonnet) · 위 "비용 줄이기" 팁. 전역 서브에이전트 모델 변경·자동 압축 비율 조정은 부작용 보고가 있어 넣지 않았다 |

---

## 문서 구조

| 문서 | 용도 | 언제 읽는가 |
|------|------|------------|
| **README.md** (이 파일) | 전체 개요 + 세 루프 설명 + 기술 스택 | 처음 볼 때 |
| `docs/REACT_FIREBASE_SETUP.md` | React+Firebase 프로젝트 세팅 체크리스트 (폴더트리·IAM·CI/CD·도메인·SEO) | 신규 프로젝트 시작 시 |
| `bootstrap.md` | 스타터킷 설치 자동화 절차 (Step 0~5) | 신규/기존 프로젝트에 설치할 때 |
| `RELEASE_NOTES.md` | 비전공자용 쉬운 업데이트 안내 (무엇을 했고 · 이제 무엇이 가능한지 · 추가된 스킬) | 새 버전 알림 링크를 눌렀을 때 |
| `CHANGELOG.md` | 버전 이력(기술 상세) + 설치된 프로젝트용 업그레이드 가이드 | 레포 업데이트를 기존 프로젝트에 반영할 때 |
| `LICENSE` | 사용 허락 조건 (구매 고객 전용 · 재배포 금지) | 도입 전 |
