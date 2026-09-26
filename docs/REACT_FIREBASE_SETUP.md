# React + Firebase 신규 프로젝트 세팅 체크리스트

> 이 키트의 웹개발 표준 스택 = **React + Vite + TypeScript + Firebase**.
> 새 웹 프로젝트를 시작할 때 이 문서 순서대로 따라가면 "코드 짤 수 있는 상태"까지 세팅이 끝납니다.
> 각 단계는 사람이 직접 해야 하는 것(계정·키 발급 등)과 AI 에이전트에게 맡길 것을 구분해 표시합니다.

---

## 에이전트 사용 가이드

> **AI 에이전트가 이 문서를 직접 읽고 있다면** 아래 규칙을 따르세요.

1. 이 문서는 **순서대로** 진행합니다 (0 → 5). 이전 단계가 끝나야 다음 단계 진행.
2. `[대괄호]`는 프로젝트 정보로 치환. 없으면 사용자에게 먼저 물어봅니다.
3. **사람이 해야 하는 단계**(Firebase 콘솔 클릭, 계정 로그인 등)는 대신 하지 말고, 정확한 절차를 안내한 뒤 완료 확인을 받으세요.
4. 완료된 세팅은 프로젝트의 `docs/questions.md`에 "세팅 완료" 로그로 남기세요.

---

## 0단계 — 프로젝트 생성 & 폴더 트리 세팅 (AI 수행)

```
이 저장소(fine-harness-react-kit)를 새 프로젝트 루트에 세팅해줘.

1. React 프로젝트가 없으면 먼저 생성:
   npm create vite@latest . -- --template react-ts

2. 아래 폴더 트리를 목표로 세팅 — **모노레포 표준**: 한 클라이언트 프로젝트 = 한 레포에
   웹앱(루트) + Cloud Functions를 함께 둔다:
   [프로젝트명]/                  ← 레포 루트 = 웹앱 루트
   ├── src/
   │   ├── app/               # 라우터·paths·providers·인증 가드
   │   ├── components/ui/     # 공용 컴포넌트 (shadcn/ui 패턴, 카탈로그 README)
   │   ├── features/           # 기능별 수직 슬라이스 (components/hooks/api/types/index)
   │   ├── lib/                # firebase·env·query-client·sentry·i18n 단일 지점
   │   ├── styles/tokens.css   # 디자인 토큰 단일 출처
   │   ├── locales/ko/         # i18n 리소스
   │   └── main.tsx
   ├── public/                 # 파비콘·폰트·manifest (generate-web-assets가 채움)
   ├── functions/              # Cloud Functions (모노레포 — Sentry AutoFix·AI 프록시 등)
   ├── docs/ knowledge/ .claude/  # 하네스 (bootstrap.md가 설치)
   ├── .github/workflows/      # react-ci.yml + firebase-hosting-deploy.yml
   ├── firebase.json / .firebaserc / firestore.rules / storage.rules
   └── CLAUDE.md               # bootstrap이 치환 설치

3. CLAUDE.md의 [기술 스택] 섹션은 아래로 고정:
   - 플랫폼: 웹 (반응형 — 모바일 우선)
   - 프레임워크: React 19 + TypeScript(strict+) + Vite
   - 백엔드: Firebase (Auth / Firestore / Storage / Hosting / Functions 중 실사용만 명시)
   - 서버 상태: TanStack Query v5 / 클라이언트 상태: Zustand v5 (rules.md § 상태관리)
   - 라우팅: React Router v7 (rules.md § 라우팅)
   - 폼: react-hook-form + zod
   - 스타일: Tailwind CSS v4 + shadcn/ui 패턴 (tokens.css 단일 소스)
   - 폰트: Pretendard Variable (tokens.css --font-sans 단일 소스)
   - 테스트: Vitest + React Testing Library (+ Playwright E2E)
   - 린터: ESLint 9 flat + typescript-eslint(strictTypeChecked) + Prettier
   - 모니터링: Sentry (웹은 Crashlytics 미지원)

4. 검증 명령어는 아래로 고정:
   1. lint      → npm run lint
   2. typecheck → npm run typecheck
   3. test      → npm run test
   4. build     → npm run build
```

---

## 1단계 — Firebase 프로젝트 생성 + 웹 앱 등록 (사람 개입 최소)

> Firebase 콘솔 로그인·프로젝트 생성은 반드시 대표/담당자 계정으로 진행 (개인 계정이 아닌 회사·법인 계정 사용 원칙 — 담당자가 바뀌어도 소유권이 남도록).

```
1. 프로젝트 생성 — CLI 우선 (콘솔 갈 필요 없음, 단 firebase login은 법인 계정으로):
   firebase projects:create [클라이언트사명]-[서비스명] --display-name "[표시명]"
   firebase use [프로젝트ID]
   - 프로젝트 ID: 전역 유일 + 생성 후 변경 불가 — 신중히 확정

2. 웹 앱 등록 + config 확보 (CLI로):
   firebase apps:create web [프로젝트명]
   firebase apps:sdkconfig web [APP_ID]
   → 출력 config를 .env의 VITE_FIREBASE_* 로 (커밋 O — 시크릿 아님, 보안은 Rules+App Check 담당)

3. Firestore 생성 (리전 asia-northeast3 권장, 되돌릴 수 없으므로 확정 후):
   gcloud firestore databases create --location=asia-northeast3 --project=[프로젝트ID]
   콘솔에서 Authentication·Storage "시작하기" (이 둘은 콘솔 개시 필요)

4. Hosting + 에뮬레이터:
   firebase init hosting    (public: dist, SPA rewrite Yes)
   firebase init emulators  (auth/firestore/storage)
   → firebase.json을 templates/firebase/firebase.json.example 기준으로 보강
     (캐시 헤더 + CSP + 보안 헤더)

5. 보안 규칙: 테스트 모드로 시작했더라도 첫 기능 개발과 함께 deny-by-default로 교체.
   규칙 파일(firestore.rules/storage.rules)은 "클라이언트 연산과 같은 커밋" 원칙 (rules.md § Firebase)
```

---

## 2단계 — 권한 / IAM / 보안 (사람 필수 개입)

```
1. 프로젝트 설정 → 사용자 및 권한(IAM)에서 팀원 추가
   - 개발 담당(개발사·사내 개발팀): 소유자(Owner) 또는 편집자(Editor)
   - 클라이언트 담당자(요청 시): 뷰어(Viewer) — 절대 소유자 권한 주지 않음
   - (외주 개발이라면) 계약 종료 후 인수인계 시: 클라이언트를 소유자로 승격 + 개발사는 다운그레이드

2. API 키 제한 (Google Cloud Console → API 및 서비스 → 사용자 인증 정보)
   - 웹 키: HTTP 리퍼러 제한 (프로덕션 도메인 + *.web.app)

3. Auth 승인된 도메인: 커스텀 도메인 + preview 채널(web.app) 추가

4. 서비스 계정 키(CI 배포용):
   - gcloud iam service-accounts keys create로 발급 (bootstrap B-8)
   - 절대 레포에 커밋하지 말 것 — GitHub Actions Secrets(FIREBASE_SERVICE_ACCOUNT)에만

5. App Check: 배포 안정화 후 reCAPTCHA Enterprise로 — 반드시 모니터링 모드부터
   (enforcement 먼저 켜면 우리 팀·CI부터 차단: unknown-unknowns #53)

6. CORS: Storage 파일을 fetch/canvas로 쓰면 cors.json을 버킷에 적용
   (gcloud storage buckets update gs://<버킷> --cors-file=cors.json).
   앱↔Functions는 Hosting /api rewrite 또는 onCall로 CORS 회피. 상세: 프로젝트 docs/CORS.md
```

---

## 3단계 — CI/CD 세팅 (AI가 템플릿 생성, 사람이 Secrets 등록)

```
1. templates/ci/react-ci.yml → .github/workflows/react-ci.yml
   - format → lint → typecheck → test → build (검증 명령어와 동일 — 로컬 통과 = CI 통과)
   - main/dev push 및 모든 PR에서 실행

2. templates/ci/firebase-hosting-deploy.yml → .github/workflows/firebase-hosting-deploy.yml
   - PR = preview 채널(7일 만료, URL 자동 코멘트) / main push = live
   - GitHub 저장소 Variables에 VITE_FIREBASE_* 등록 (빌드 주입용)
   - Secrets에 FIREBASE_SERVICE_ACCOUNT 등록 (사람이 직접)

3. Dependabot 또는 Renovate 활성화 (공급망 관리 — lockfile 커밋 필수)

4. (Sentry 도입 시) SENTRY_AUTH_TOKEN을 Secrets에 — 소스맵 업로드용, VITE_ 접두사 금지
```

---

## 4단계 — 도메인 / SEO / 웹 에셋 (스토어 등록의 웹 대응물)

```
1. 커스텀 도메인: Hosting → 커스텀 도메인 연결 (DNS 전파 시간 존재 — 데드라인 있으면 초기에)

2. 웹 에셋: 로고를 web-assets/logo-source/에 배치 → /generate-web-assets 실행
   → 파비콘 세트·PWA 아이콘·OG 이미지(1200×630)·manifest 생성 + index.html 연결

3. SEO 기본: index.html 메타(title/description/og:*) 실문구 확정,
   라우트별 <title>은 React 19 네이티브 metadata로 (react-helmet 불필요),
   크롤링이 중요한 공개 페이지가 많으면 prerendering 검토 (인증 뒤 앱이면 불필요)

4. 성능 목표: LCP < 2.5s / INP < 200ms / CLS < 0.1 (75퍼센타일),
   초기 JS(gzip) 250KB 이하 — Lighthouse로 배포 전 1회 측정해 기준선 기록
```

---

## 5단계 — 세팅 완료 확인

```
아래를 모두 확인한 뒤 "세팅 완료"로 기록:

□ npm run lint / typecheck / test / build 로컬에서 통과
□ .env의 VITE_FIREBASE_* 채워짐 + .env.local·.secrets/ gitignore 처리
□ 에뮬레이터로 로컬 개발 동작 (npm run dev + firebase emulators:start)
□ Firestore/Storage 규칙 deny-by-default 확인
□ Firebase IAM에 팀원만 등록, 클라이언트는 뷰어 이하
□ GitHub Actions CI 1회 이상 그린 확인
□ preview 채널 1회 배포 + Auth 승인된 도메인 확인
□ Sentry 연동 여부 결정 (프로덕션 전 필수 권장)

완료 후 프로젝트 docs/questions.md에 아래 형식으로 기록:
## YYYY-MM-DD
- [React+Firebase 세팅 완료] Firebase 프로젝트: [id], CI: 그린, 도메인: [상태]
```

---

## 관련 문서

- 설치 자동화: `bootstrap.md`
- CI 템플릿: `templates/ci/`
