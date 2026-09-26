# 설치 체크리스트

> `bootstrap.md`가 항목을 채우며 진행한다. 이후에도 "지금 이 프로젝트에 뭐가 연결돼 있는지" 확인하는
> 용도로 계속 쓴다 — MCP/CLI/API가 늘어날 때마다 이 파일에도 추가할 것.
>
> 스타터킷 버전: `.claude/starter-version` (설치일 `[YYYY-MM-DD]`). 새 버전이 나오면 세션 시작 훅이 알리고,
> `/update-starter`가 반영 + 변경 내역 링크를 보여준다.

## ⚡ Day 0 — 설치 직후 바로 확인할 것

설치(bootstrap)가 끝나는 시점에 에이전트가 이 섹션의 미완료 항목을 사용자에게 브리핑한다.
아래는 방치하면 **첫 빌드·첫 배포에서 반드시 막히는** 항목만 모은 것 (상세는 아래 카테고리 섹션 참조):

- [ ] Firebase 콘솔에서 Auth/Firestore/Storage 활성화됨 (Firebase 사용 시)
- [ ] `.env`에 `VITE_FIREBASE_*` config 값 채워짐 (없으면 앱이 흰 화면)
- [ ] Firestore/Storage 보안 규칙 — 테스트 모드(`allow if true`) 아님 확인
- [ ] `.env.local`·`.secrets/` 가 `.gitignore`에 포함 확인 (시크릿은 VITE_ 접두사 금지)
- [ ] `.mcp.json` 등록됐으면 **Claude Code 새 세션 시작** (재시작 전엔 MCP 도구 안 보임)
- [ ] CI 워크플로우 설치 + 첫 push로 그린 1회 확인
- [ ] 검증 명령어 4종(lint/typecheck/test/build)이 현재 머신에서 실제로 도는지 1회 실행
- [ ] Firebase Hosting 연결 + preview 채널 1회 배포 확인 (배포 계획 있으면)

## CLI 연동

**필수**
- [ ] Node.js 20+ / npm — `node --version`
- [ ] GitHub CLI (`gh`) — 인증됨, 저장소: `[owner/repo]`
- [ ] Firebase CLI (`firebase`) — 로그인됨(법인 계정), 프로젝트: `[project-id]` (Firebase 미사용 프로젝트면 해당없음)
- [ ] Google Cloud CLI (`gcloud`) — 로그인됨(firebase와 같은 법인 계정) + `config set project` 일치.
      서비스 계정 키 발급·Firestore DB 생성·API 활성화·IAM 작업 담당

**선택 (필요 시점에 설치)**
- [ ] Playwright — E2E 테스트·`/generate-web-assets` OG 이미지 렌더링에 필요 (`npx playwright install chromium`)
- [ ] Sentry CLI/계정 — `/setup-sentry-autofix` 실행 시 필요 (스킬이 자체 안내)

## MCP 서버
- [ ] Firebase MCP — 설치 시(bootstrap Step 0.5-I) 또는 나중에 `/setup-firebase-mcp`로 등록. 등록된 제품: `[firestore, auth, ... 또는 미설치]`
- [ ] (신규 MCP 추가 시 이 아래에 항목 추가)

## API / 시크릿 (`.secrets/` + `.env.local` — 절대 커밋 금지)
- [ ] AI API 키 — Cloud Functions 시크릿(`firebase functions:secrets:set`) : `[미등록 — AI 기능 착수 시 등록이 기본. 클라이언트 .env(VITE_)에 넣지 않는다]`
- [ ] Sentry DSN — `.env`의 `VITE_SENTRY_DSN` (DSN은 공개 가능 값) : `[미등록 — 에러 모니터링 착수 시]`
- [ ] Figma Access Token — `.secrets/.env` : `[미등록 — Figma 쓰게 되면 등록. 디자인 소스가 Figma면 설치 때 등록됨]`
- [ ] Firebase 서비스 계정 키 — GitHub Actions Secrets `FIREBASE_SERVICE_ACCOUNT` (CI 배포용)

## 한국어 품질 도구
- [x] fluent-korean output-style — `.claude/output-styles/fluent-korean.md` + `settings.json`의 `outputStyle`로
      **프로젝트에 자동 설치**됨 (에이전트의 보고·질문 한국어 품질. 새 세션부터 적용). 끄려면 settings.json에서
      `outputStyle` 삭제.
- [ ] im-not-ai (`/humanize-scan`·`/humanize-korean`) — 사용자 **전역** 설치(프로젝트 파일 아님). 랜딩·온보딩·
      이메일·공지 같은 300자+ 사용자향 산문의 AI 티 점검용 (rules.md § 한국어 카피).
      설치: Claude Code에서 `/plugin marketplace add epoko77-ai/im-not-ai` → `/plugin install humanize-korean@im-not-ai`
      (또는 클론 + `./install.sh --claude-only`) : `[설치됨 / 미설치 — 산문 카피 작업 시작 전에]`

## 브라우저 확장
- [ ] Claude in Chrome — 브라우저 QA·콘솔 자동화용.
      설치: https://claude.ai/chrome : `[연결됨 / 미설치 — 필요 시]`

## Firebase 설정 (Firebase 사용 프로젝트만)
- [ ] Authentication 활성화 (+ 로그인 방법 선택)
- [ ] Firestore 활성화 (리전: `[asia-northeast3 등]`)
- [ ] Storage 활성화
- [ ] Hosting 연결 (`firebase init hosting` — SPA rewrite + 캐시 헤더)
- [ ] 웹 앱 등록 → config를 `.env`의 `VITE_FIREBASE_*`로
- [ ] Firestore/Storage 보안 규칙 — 테스트 모드 아님 확인 (배포 전 필수)
- [ ] 에뮬레이터 설정 (`firebase init emulators` — auth/firestore/storage) + 로컬 개발 연결 확인
- [ ] CORS (docs/CORS.md) — Storage 파일을 fetch/canvas로 쓰면 `cors.json`을 버킷에 적용
      (`gcloud storage buckets update gs://<버킷> --cors-file=cors.json`). 앱↔Functions는 Hosting
      `/api` rewrite 또는 onCall로 회피 : `[적용/해당없음]`
- [ ] 테스트 계정 규약 확인 (`docs/TEST_ACCOUNTS.md`) — 전화 010범위/123456·이메일 @test.local,
      dev+에뮬레이터 전용(프로덕션 하드 차단). `npm run seed:test`로 시드. 로그인 UI에 test-auth 배선됨: `[예/아니오]`
- [ ] (앱스토어 심사 등) 프로덕션 QA 계정 필요 시 콘솔 테스트번호(≤10) 등록 — TEST_ACCOUNTS.md 하단 기록
- [ ] App Check (배포 안정화 후) : `[미설정 — 모니터링 모드부터 시작]`
- [ ] Auth authorized domains에 preview 채널 도메인 추가 (`[project].web.app`, `*.web.app` 프리뷰)

## CI/CD
- [ ] `.github/workflows/react-ci.yml` 설치 (`templates/ci/react-ci.yml` 기반)
- [ ] `.github/workflows/firebase-hosting-deploy.yml` 설치 (PR preview + main live)
- [ ] GitHub Actions Secrets 등록 (`FIREBASE_SERVICE_ACCOUNT`)
- [ ] CI 1회 이상 그린 확인
- [ ] Dependabot/Renovate 활성화 : `[활성 / 아직]`

## Ops Loop 모듈 (선택 설치 — 파일은 항상 설치되지만 실행은 별도)
- [ ] `/setup-sentry-autofix` 실행 여부: `[실행함 / 아직 안 함]`
- [ ] `/setup-auto-triage` 실행 여부: `[실행함 / 아직 안 함]`
- [ ] `/setup-perf-monitor` 실행 여부: `[실행함 / 아직 안 함 — 첫 배포 후]`
      성능 기준선: `[YYYY-MM-DD: LCP ___ / CLS ___ / TBT ___ 또는 미측정]`
- [ ] `/setup-firebase-mcp` 실행 여부: `[실행함 / 아직 안 함]`

## 웹 에셋 · SEO
- [ ] 마스터 로고 등록 — `web-assets/logo-source/logo.png` (또는 svg)
- [ ] `/generate-web-assets` 실행 — 파비콘 세트·PWA 아이콘·OG 이미지 생성 완료
- [ ] index.html 메타(title·description·og:*)가 실제 서비스 문구로 채워짐
- [ ] `<Seo>`(src/components/Seo.tsx) SITE_NAME이 실제 서비스명으로 치환 + 주요 라우트에 배선
- [ ] `public/robots.txt` 크롤링 정책 확인 (스테이징/미출시면 `Disallow: /`) : `[프로덕션/차단]`
- [ ] og:image 절대 URL 확정 (도메인 확정 후 — 카카오톡/슬랙 미리보기)

## 자동화 스케줄 (선택)
- [ ] `@rule-promoter` 스케줄 등록 여부: `[등록함 / 수동 실행]`
- [ ] `@mistake-compressor` 스케줄 등록 여부: `[등록함 / 수동 실행]`

---
설치 진행 중 채워지지 않은 항목이 있어도 정상 — 프로젝트 성격에 따라 "해당없음"인 항목이 많다.
빈 대괄호(`[...]`)가 남아있으면 아직 확정 안 된 것이니 사람이 채울 것.
