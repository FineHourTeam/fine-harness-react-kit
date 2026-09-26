# Bootstrap — Agent Installation Guide

이 문서를 읽은 에이전트는 아래 절차를 **정확히 순서대로** 실행한다.
각 Step을 완료한 후 다음으로 진행. 실패 시 중단하고 사용자에게 보고.

---

## Step 0: 사전 정찰 → 질문 (답 받기 전 진행 금지)

### 0-A. 사전 정찰 (질문하기 전 필수 — 뻔히 알 수 있는 걸 묻지 않는다)

질문 전에 프로젝트 상태를 먼저 파악한다:

```bash
ls -la                    # 빈 폴더인가, 기존 프로젝트인가
cat package.json          # 있으면: name(→프로젝트명 추론), firebase/react 의존성, scripts
ls src/ 2>/dev/null       # 기존 코드 구조
ls .firebaserc firebase.json src/lib/firebase.ts 2>/dev/null   # Firebase 연동 흔적
git remote -v             # GitHub 연결 여부
```
README·기획 문서(docs/plan.md 등)가 있으면 읽고 컨셉·톤도 추론한다.

- **신규(빈 폴더 / package.json 없음)**: "React 프로젝트가 아직 없네요 — Vite로 생성부터 할까요?
  (`npm create vite@latest . -- --template react-ts`)" 를 첫 질문으로.
- **기존 프로젝트**: 파악한 값은 묻지 않고 **확인만** 받는다 — "package.json을 보니 프로젝트명은
  safework, Firebase(firestore·auth)를 이미 쓰고 있네요. 맞나요?" 식으로. 정찰로 알 수 없는 것만
  아래에서 질문.

### 0-B. 질문 (정찰로 못 채운 항목만, 한 번에 하나씩)

1. **프로젝트명은 무엇인가요?** (package.json name으로 추론됐으면 확인만)
   예: "PickingCert", "MyApp"

2. **제품 컨셉을 한 줄로 설명해주세요.** (기획 문서에서 추론됐으면 확인만)
   예: "자격증 발급을 셀프서비스로 만드는 플랫폼"

3. **톤앤매너 키워드 2-3개?**
   예: "신뢰감 있는, 깔끔한, 전문적인"

4. **Firebase 사용하나요?** (Y/N — package.json에 firebase 있으면 Y로 추론하고 확인만)

5. **AI 기능 사용하나요?** (Y/N — 아키텍처 결정용. **API 키는 지금 안 받는다**, E단계 참조)

6. **세계관/브랜드 캐릭터가 있나요?**
   있으면 간단히 설명, 없으면 "없음"

7. **디자인시스템 소스가 있나요?** (git URL / Figma / 없음)
   토큰(색·타이포·간격) 저장소가 있으면 그 git URL, Figma면 "Figma", 없으면 "없음"

8. **UI 문체는 해요체인가요, 합쇼체인가요?** (기획 문서·기존 화면·common.json에서 추론됐으면 확인만)
   해요체("저장했어요") = 토스·당근 계열의 친근함, 합쇼체("저장되었습니다") = 금융·공공·B2B 격식.
   기본값 해요체. 화면·토스트·에러·이메일이 **하나로 통일**되는 게 핵심 — 섞이는 게 대표적인 AI 티.

답을 아래 변수로 저장:
- `{{PROJECT_NAME}}`
- `{{PROJECT_CONCEPT}}`
- `{{TONE_KEYWORDS}}`
- `{{FIREBASE_ENABLED}}` (Y/N)
- `{{AI_ENABLED}}` (Y/N)
- `{{BRAND_WORLD}}` (설명 또는 빈 문자열)
- `{{DESIGN_SYSTEM_SOURCE}}` (git URL / "Figma" / "없음")
- `{{SPEECH_LEVEL}}` (해요체 / 합쇼체)
- `{{TODAY}}` (오늘 날짜 YYYY-MM-DD 형식, 자동)

---

## Step 0.5: 서비스 연동 (FIREBASE_ENABLED=Y 또는 기타 조건 충족 시)

Step 0 답변을 기반으로 필요한 외부 서비스를 연동한다.
각 항목은 조건부. 해당 없으면 건너뜀.

---

### A. GitHub 연동 (항상 실행)

#### A-1. gh CLI 확인
```bash
gh --version
```
없으면: `winget install GitHub.cli` / `brew install gh` 또는 https://cli.github.com 안내 후 **대기**.

#### A-2. 로그인 상태 확인
```bash
gh auth status
```
미로그인 시:
```bash
gh auth login
```
브라우저 인증 완료까지 대기.

#### A-3. 원격 저장소 확인 (반드시 먼저 질문)
```bash
git remote -v
```

**remote 없는 경우** — 사용자에게 **먼저 질문**: "기존 GitHub 저장소에 연결할까요, 새로 만들까요?"
- (a) **새 저장소 생성 (CLI로 바로)** → `gh repo create {{PROJECT_NAME}} --private --source=. --push`
  (조직 소유로 만들려면 `gh repo create <org>/{{PROJECT_NAME}} ...` — 어느 계정/조직 소유인지도 질문)
- (b) 기존 저장소 연결 → URL 입력 받아 `git remote add origin <URL>`
- (c) 나중에 직접 설정 (건너뜀 — setup-checklist.md에 미완료로 남김)

**remote 있는 경우** — 현재 연결된 repo 정보 출력 후 "이 저장소가 맞나요?" 확인받고 계속.

---

### B. Firebase 연동 (FIREBASE_ENABLED = Y인 경우만)

#### B-1. CLI 확인 (firebase + gcloud)
```bash
firebase --version
gcloud --version
```
- `firebase` 없으면: `npm install -g firebase-tools` 안내 후 **대기**.
- `gcloud` 없으면: 설치 안내 후 **대기** — Windows `winget install Google.CloudSDK` /
  macOS `brew install google-cloud-sdk` / 기타 https://cloud.google.com/sdk/docs/install

#### B-2. 로그인 (둘 다 법인 계정)
```bash
firebase login
gcloud auth login
```
이미 로그인 상태면 건너뜀 (`firebase login:list` / `gcloud auth list`로 확인).
두 CLI 모두 **같은 법인 계정**으로 로그인됐는지 확인 — 계정이 갈리면 이후 권한 오류의 주 원인.

#### B-3. 프로젝트 선택 또는 생성 (반드시 먼저 질문)
```bash
firebase projects:list
```
목록을 보여주고 사용자에게 **먼저 질문**: "기존 Firebase 프로젝트를 쓸까요, 새로 만들까요?"
- **기존 프로젝트 사용**: 프로젝트 ID 입력 받아 `firebase use <PROJECT_ID>` 실행
- **새 프로젝트 생성 (CLI로 바로)**: 프로젝트 ID 확정 받아
  `firebase projects:create <PROJECT_ID> --display-name "<표시명>"` 실행 → `firebase use <PROJECT_ID>`
  (ID는 전역 유일·생성 후 변경 불가이므로 `[클라이언트]-[서비스명]` 형식으로 신중히 확정)
- CLI 생성이 실패하는 경우(조직 정책 등)에만 콘솔(https://console.firebase.google.com) 생성으로 폴백

프로젝트 확정 후 gcloud도 같은 프로젝트로 맞춘다:
```bash
gcloud config set project <PROJECT_ID>
```

#### B-4. Blaze 플랜 확인
AI 기능(`AI_ENABLED=Y`) 또는 Cloud Functions(Sentry AutoFix 포함) 사용 시 Blaze(종량제) 필요.
사용자에게 안내:
```
⚠️ AI 기능 / Cloud Functions 사용 시 Firebase Blaze 플랜 필요.
   Firebase 콘솔 → 프로젝트 설정 → 사용량 및 결제에서 확인.
   확인 후 계속 진행하세요.
```
확인 여부 물어보고 Y일 때 계속.

#### B-5. 서비스 활성화 — CLI로 되는 것 먼저, 나머지만 콘솔

**Firestore는 CLI로 바로 생성** (리전은 되돌릴 수 없으므로 먼저 질문 — 한국 서비스면 `asia-northeast3` 서울 제안):
```bash
gcloud services enable firestore.googleapis.com
gcloud firestore databases create --location=<리전> --project=<PROJECT_ID>
```
⚠️ **undelete로 복구한 프로젝트는 (default) DB를 쓰지 말 것** — 원 프로젝트의 삭제 파이프라인이
뒤늦게 실행되어 "Cannot serve requests because the database was deleted" 상태로 깨질 수 있다
(list엔 보이는데 서빙 불가·delete는 NOT_FOUND·create는 already exists인 좀비 상태 — 2026-07
실제 프로젝트 실측). 복구 프로젝트면 처음부터 named DB로 생성하고 클라이언트/규칙을 맞춘다:
`gcloud firestore databases create --database=<서비스명> ...` +
`initializeFirestore(app, {}, "<서비스명>")` + firebase.json `firestore.database`.

관련 API도 미리 활성화 (무해 — 콘솔 클릭 수를 줄여줌):
```bash
gcloud services enable identitytoolkit.googleapis.com firebasestorage.googleapis.com \
  --project=<PROJECT_ID>
```

**Auth 초기화·Storage 기본 버킷도 CLI(REST)로 생성** — 콘솔 "시작하기"와 동일 효과
(2026-07 실제 프로젝트 실측. `x-goog-user-project` 헤더 없으면 403 SERVICE_DISABLED):
```bash
TOKEN=$(gcloud auth print-access-token)
# Authentication 초기화 (콘솔 Auth "시작하기" 대체) — 성공 시 {} 반환
curl -s -X POST "https://identitytoolkit.googleapis.com/v2/projects/<PROJECT_ID>/identityPlatform:initializeAuth" \
  -H "Authorization: Bearer $TOKEN" -H "x-goog-user-project: <PROJECT_ID>" \
  -H "Content-Type: application/json" -d '{}'
# Storage 기본 버킷 생성 (콘솔 Storage "시작하기" 대체) → <PROJECT_ID>.firebasestorage.app
curl -s -X POST "https://firebasestorage.googleapis.com/v1beta/projects/<PROJECT_ID>/defaultBucket" \
  -H "Authorization: Bearer $TOKEN" -H "x-goog-user-project: <PROJECT_ID>" \
  -H "Content-Type: application/json" -d '{"location": "<리전>"}'
# 승인 도메인 등록 — initializeAuth는 콘솔 초기화와 달리 기본 승인 도메인(localhost 포함)을
# 넣어주지 않는다 (2026-07 실제 프로젝트 실측: 소셜 로그인 시 unauthorized-domain 원인)
curl -s -X PATCH "https://identitytoolkit.googleapis.com/admin/v2/projects/<PROJECT_ID>/config?updateMask=authorizedDomains"   -H "Authorization: Bearer $TOKEN" -H "x-goog-user-project: <PROJECT_ID>"   -H "Content-Type: application/json"   -d '{"authorizedDomains": ["localhost", "<PROJECT_ID>.firebaseapp.com", "<PROJECT_ID>.web.app", "<실제 Hosting 도메인(접미사 붙었으면 그것)>"]}'
```

**소셜 로그인 공급자만 콘솔 1클릭 필요** — Google 등 OAuth 공급자는 콘솔이 OAuth 클라이언트를
자동 생성해주는데, 이 자동 생성이 공개 API에 없다 (`admin/v2 defaultSupportedIdpConfigs`가
client_id를 요구 — `INVALID_CONFIG: client_id cannot be empty`). 이메일/전화 등 비-OAuth
공급자는 `admin/v2 .../config` PATCH로 활성화 가능.

| 서비스 | 확인 위치 |
|-------|---------|
| Auth 로그인 공급자 (Google 등 소셜) | 콘솔 → Authentication → 로그인 방법 → 공급자 사용 설정 |

⚠️ Google 공급자 활성화 후 프로덕션에서 `400 redirect_uri_mismatch`가 나면: 자동 생성된 OAuth
클라이언트(GCP 콘솔 → API 및 서비스 → 사용자 인증 정보)의 "승인된 리디렉션 URI"에
`https://<실제 authDomain>/__/auth/handler`를 추가해야 한다 — 특히 기본 사이트 ID에 접미사가
붙은 프로젝트에서 발생 (2026-07 실제 프로젝트 실측). authDomain은 사용자가 실제 접속하는 Hosting
도메인으로 맞추는 것을 권장 (팝업 same-origin — 서드파티 쿠키 이슈도 회피). OAuth 클라이언트
편집은 공개 API가 없어 콘솔 수동.

사용자가 "완료" 확인 후 다음 단계 (블로커 아니면 나중에 해도 됨 — setup-checklist에 기록).

#### B-6. 웹 앱 등록 + config를 .env로

```bash
firebase apps:list
# 웹 앱 없으면:
firebase apps:create web {{PROJECT_NAME}}
# config 조회:
firebase apps:sdkconfig web <APP_ID>
```
출력된 config 값으로 프로젝트 루트 `.env` 작성 (Firebase config는 시크릿 아님 — 커밋 O):
```
VITE_FIREBASE_API_KEY=...
VITE_FIREBASE_AUTH_DOMAIN=...
VITE_FIREBASE_PROJECT_ID=...
VITE_FIREBASE_STORAGE_BUCKET=...
VITE_FIREBASE_MESSAGING_SENDER_ID=...
VITE_FIREBASE_APP_ID=...
VITE_USE_EMULATORS=true
```
⚠️ **진짜 시크릿은 VITE_ 접두사 금지** — 번들에 평문 박제된다. AI 키 등은 E단계 정책대로.

#### B-7. Hosting + 에뮬레이터 초기화

```bash
firebase init hosting     # public: dist, SPA rewrite: Yes, GitHub 자동 배포: No(우리 템플릿 사용)
firebase init emulators   # auth, firestore, storage 선택
```
생성된 `firebase.json`을 `templates/firebase/firebase.json.example` 기준으로 보강
(캐시 헤더·보안 헤더·CSP — 사용자에게 diff 보여주고 승인).

#### B-8. 서비스 계정 키 (CI 배포용 — 배포 파이프라인 붙일 때)
```bash
gcloud iam service-accounts list --project=<PROJECT_ID> --filter="email~firebase-adminsdk"
gcloud iam service-accounts keys create .secrets/firebase-service-account.json \
  --iam-account=<이메일> --project=<PROJECT_ID>
```
(키 발급은 되돌리기 어려운 보안 동작 — 실행 전 명령을 보여주고 승인받을 것)
키 확보 후: `.secrets/` 생성 → `.gitignore`에 `.secrets/` 추가 → GitHub Actions Secret
`FIREBASE_SERVICE_ACCOUNT`로 등록 안내 (`gh secret set FIREBASE_SERVICE_ACCOUNT < .secrets/firebase-service-account.json`).
건너뜀 선택 시: setup-checklist.md에 미완료로 남김.

---

### C. Sentry 연동 (선택 — 프로덕션 배포 계획 시 권장)

웹은 Crashlytics가 없다 — 에러 모니터링은 Sentry가 표준. 사용자에게 질문:
**Sentry 에러 모니터링을 지금 연동하나요?** (Y/N — 나중에 `/setup-sentry-autofix` 전에만 하면 됨)

Y인 경우:
1. https://sentry.io 프로젝트 생성(React) 안내 → DSN 입력 받기
2. `.env`에 `VITE_SENTRY_DSN=<DSN>` 추가 (DSN은 공개 가능 값)
3. `npm install @sentry/react` + `templates/react/src/lib/sentry.ts` 복사 +
   `src/main.tsx` 최상단 `import "./lib/sentry";` 추가
4. 소스맵 업로드(`@sentry/vite-plugin` + `SENTRY_AUTH_TOKEN` CI 시크릿)는
   vite.config.example.ts 주석 참조로 안내 — 토큰은 **VITE_ 접두사 금지**

N이면 setup-checklist.md에 `[미등록 — 에러 모니터링 착수 시]`로 남김.

---

### D. (예약) 네이티브 앱 섹션 없음

웹 프로젝트라 스토어 등록 절차가 없다. 대신 도메인·SEO 준비가 대응물:
- 커스텀 도메인 계획 있으면 사용자에게 확인 → Hosting 도메인 연결은 콘솔 수동(전파 시간 존재) —
  setup-checklist.md에 기록만.
- OG 이미지·파비콘은 `/generate-web-assets` 스킬로 나중에 생성.

---

### E. AI 서비스 연동 (AI_ENABLED = Y인 경우만) — 키 수령은 기본적으로 지연

어떤 AI 서비스(Claude/Gemini/OpenAI/미정)를 쓸지는 물어봐도 되지만(아키텍처 참고용),
**API 키는 설치 시점에 받지 않는 게 기본**이다 — 실제로 AI 기능 개발에 착수할 때 받아도 늦지 않다.

- 기본 동작: 키를 받지 않고 `docs/setup-checklist.md`의 API 키 항목에
  `[미등록 — AI 기능 착수 시 Functions 시크릿으로 등록]`으로 남긴다.
- **클라이언트(.env VITE_)에 AI 키를 넣는 선택지는 제시 자체를 금지** — 번들에 공개된다.
  AI 호출은 Cloud Functions 경유가 표준, 키는 `firebase functions:secrets:set`으로.

---

### F. Figma 연동 (선택) — 디자인시스템 소스가 Figma일 때만 지금, 그 외엔 지연

- `{{DESIGN_SYSTEM_SOURCE}}`가 "Figma"면 (H단계 토큰 추출에 필요하므로) 지금 연동:
  Figma Personal Access Token 입력 받기 → `.secrets/.env`에 `FIGMA_ACCESS_TOKEN=<키>` 저장,
  CLAUDE.md에 Figma 파일 URL 안내 추가.
- 그 외에는 **묻지도 받지도 않는다**. `docs/setup-checklist.md`에 `[미등록]`으로만 남긴다.

---

### G. 자동화 스케줄 설정 (선택, GitHub 연동 완료 후)

사용자에게 질문: **에이전트 자동화 스케줄을 설정하나요?** (Y/N)

에이전트 2개가 매일 자동으로 실행됩니다:
- `@rule-promoter` — recent.md에서 반복 패턴을 찾아 `docs/proposals.md`에 승격 제안 기록
- `@mistake-compressor` — recent.md가 200줄 초과 시 archive/로 압축 후 커밋

Y인 경우: Claude Code에서 `/schedule` 실행 안내 (저장소 URL + 매일 09:00 + 두 에이전트 역할 설명).
N인 경우: 수동 실행 안내 (`@rule-promoter` 주 1회 / `@mistake-compressor` 200줄 초과 시).

---

### H. 디자인시스템 연동 ({{DESIGN_SYSTEM_SOURCE}} 기반, 선택)

Step 0 질문 7의 `{{DESIGN_SYSTEM_SOURCE}}`로 분기. 목적: 개발 시작 시점에
디자인 토큰을 소스에서 뽑아 `src/styles/tokens.css`로 반영하고, 이후 모든 UI가 그 토큰만
재사용하도록 강제한다(하드코딩 hex·매직넘버 금지, 다크모드 필수).

**git URL인 경우**:

1. 얕은 클론: `git clone --depth 1 <URL> .cache/design-system`
   → `.gitignore`에 `.cache/` 추가 (없으면 append).
2. 포맷 자동 감지: W3C Design Tokens / Style Dictionary / Figma Tokens export /
   CSS·SCSS 변수 / Tailwind config / 컴포넌트 라이브러리(대표 팔레트만 추출)
3. 추출: 색상 팔레트(+라이트/다크 대응), 타이포(family), radius.
   추출 결과가 **5색(hue 기준, 상태색 3종 제외)을 넘으면** 사용자에게 축소 확인 —
   rules.md § 팔레트 정량 상한(3~5색)이 기본값이다.
4. `templates/react/src/styles/tokens.css`를 베이스로 값만 치환해
   `src/styles/tokens.css` 생성 (shadcn 위계에 매핑).
5. `knowledge/design-system.md`의 **소스 URL·토큰 매핑표·마지막 동기화일**을 채운다.
6. 확인: `npm run build` 통과 + 라이트/다크 양쪽에서 토큰이 정의됐는지.

**"Figma"인 경우**: F단계 토큰으로 Figma에서 추출하고, 4~6을 동일 적용.

**"없음"인 경우**: 건너뛰지 말고 **브랜드색 질문은 필수** — "브랜드 주조색이 있나요? (hex 값 /
'제안해줘' / 미정)". tokens.css 기본 primary는 의도적 무채색 플레이스홀더라 치환 없이는 흑백 앱이
된다. '제안해줘'면 `{{TONE_KEYWORDS}}`에 맞는 후보 2~3색을 제시해 고르게 한다 (보라·인디고·기본
블루는 후보에서 제외 — rules.md § 팔레트 정량 상한의 AI 기본색 금지). 확정색으로 `--primary` 계열만
조정하고, design-system.md의 소스를 "없음(시드 팔레트)"으로 기록. 이후 규칙(토큰 재사용·다크 필수)은
동일 적용.

---

### I. MCP 등록 (FIREBASE_ENABLED = Y인 경우 — B단계 완료 직후 권장)

B단계에서 firebase CLI 로그인·프로젝트 연결이 이미 끝났으므로, 이 시점에 공식 Firebase MCP 서버를
바로 등록한다 (별도 시크릿·키 발급 불필요 — CLI 로그인 세션을 그대로 사용).

1. `package.json`·`src/lib/firebase.ts`에서 실사용 제품을 자동 제안
   (기본 3종: firestore, auth, storage) → 사용자 확인.
2. 프로젝트 루트 `.mcp.json` 작성 (기존 파일 있으면 다른 서버 설정 보존하며 병합).
   **저장 전 파일 내용을 사용자에게 보여주고 승인** (커밋되어 팀 공유되는 파일):
   ```json
   {
     "mcpServers": {
       "firebase": {
         "command": "npx",
         "args": ["-y", "firebase-tools@latest", "mcp", "--only", "<확정한 제품, 쉼표구분>"]
       }
     }
   }
   ```
3. 안내: "Claude Code 재시작(새 세션) 후 Firebase MCP 도구가 활성화됩니다."

건너뛴 경우: 나중에 `/setup-firebase-mcp`로 등록 가능함을 안내.

---

### J. Claude in Chrome 확장 확인 (선택 — 브라우저 QA에 필요)

브라우저 QA 워크플로우가 이 확장을 쓴다. `mcp__claude-in-chrome__*` 도구가 보이는지 확인하고, 없으면:

```
🌐 Claude in Chrome 확장이 아직 연결되지 않았습니다.
   실브라우저 QA(로그인 세션 유지 테스트 등)에 필요합니다.
   설치: https://claude.ai/chrome
   지금 안 해도 됩니다 — 필요해지는 시점에 하면 됨.
```

설치 여부를 `docs/setup-checklist.md`에 기록하고 계속 진행 (블로커 아님).

---

### K. 한국어 품질 도구 확인 (선택 — 긴 사용자향 카피의 AI 티 점검에 필요)

fluent-korean output-style(에이전트의 보고·질문 한국어 품질)은 Step 2에서 프로젝트에 **자동 설치**된다
(`.claude/output-styles/` + settings.json `outputStyle`) — 여기서 할 일 없음.
im-not-ai(`/humanize-scan`·`/humanize-korean` — 랜딩·온보딩·이메일·공지 같은 산문 카피의 AI 티 탐지·윤문)는
**사용자 전역** 도구라 프로젝트에 설치하지 않는다. `~/.claude/skills/humanize-korean`(또는 플러그인
`humanize-korean@im-not-ai`)이 있는지 확인하고, 없으면:

```
✍️ im-not-ai(한글 AI 티 제거)가 아직 설치되지 않았습니다.
   랜딩·온보딩·이메일·공지처럼 긴 한국어 카피를 쓸 때 /humanize-scan으로 AI 티를 점검하는 데 씁니다.
   설치(Claude Code 안에서):  /plugin marketplace add epoko77-ai/im-not-ai
                             /plugin install humanize-korean@im-not-ai
   지금 안 해도 됩니다 — 산문 카피 작업을 시작할 때 하면 됨.
```

설치 여부를 `docs/setup-checklist.md` § 한국어 품질 도구에 기록하고 계속 진행 (블로커 아님).

---

### Step 0.5 완료 보고

연동 결과 요약 출력:

```
🔗 서비스 연동 결과:

GitHub:    ✅ 연결됨 (github.com/user/repo)
Firebase:  ✅ 프로젝트 연결됨 (project-id)
           ✅ 웹 앱 등록 + .env VITE_FIREBASE_* 작성
           ✅ Hosting/에뮬레이터 초기화 (또는 ⏭️ 건너뜀)
Sentry:    ✅ DSN 등록 + lib/sentry.ts 연결 (또는 ⏭️ 건너뜀)
AI:        ⏭️ 키 미수령 (착수 시 Functions 시크릿 — 기본 정책)
Figma:     ⏭️ 건너뜀
디자인:    ✅ <소스> → src/styles/tokens.css 생성 + design-system.md 매핑표 기록
           (또는 ⏭️ 시드 팔레트)
스케줄:    ✅ rule-promoter + mistake-compressor 매일 09:00 (또는 ⏭️ 수동 실행)
MCP:       ✅ firebase → .mcp.json (제품: firestore, auth, ...) — 새 세션부터 활성
브라우저:  ✅ Claude in Chrome 연결됨 (또는 ⏭️ 미설치)
한국어:    ✅ fluent-korean output-style (Step 2 자동, 새 세션부터) · im-not-ai ✅ 전역 설치됨 (또는 ⏭️ 미설치)

.gitignore에 추가된 항목: .secrets/  .cache/  .env.local
```

이 연동 결과는 Step 2에서 `docs/setup-checklist.md`가 설치된 뒤, Step 5에서 체크박스로 옮겨 적는다.

---

## Step 1: 기존 파일 체크

프로젝트 루트에서 아래 확인:

| 파일/폴더 | 동작 |
|----------|------|
| `CLAUDE.md` 존재 | `CLAUDE.md.bak`으로 백업 후 계속 |
| `knowledge/` 폴더 존재 | **중단**하고 사용자에게 보고 (덮어쓰기 위험) |
| `.claude/agents/` 존재 | 개별 파일별로 사용자에게 덮어쓰기 확인 |
| `.claude/settings.json` 존재 | 덮어쓰지 말고 **병합** — 기존 permissions/hooks 보존하며 템플릿 항목 추가, 결과를 사용자에게 보여주고 승인 |
| `docs/questions.md` 존재 | 건드리지 말 것 (기존 로그 보존) |
| `docs/insights.md` 존재 | 건드리지 말 것 |

---

## Step 2: 파일 복사

`/tmp/rcs/template/` (또는 설치 위치)의 파일을 프로젝트 루트로 복사.

### 복사 목록

```
template/CLAUDE.md                              → ./CLAUDE.md
template/docs/questions.md                      → ./docs/questions.md
template/docs/insights.md                       → ./docs/insights.md
template/docs/proposals.md                      → ./docs/proposals.md
template/docs/setup-checklist.md                → ./docs/setup-checklist.md
template/knowledge/INDEX.md                     → ./knowledge/INDEX.md
template/knowledge/rules.md                     → ./knowledge/rules.md
template/knowledge/pitfalls.md                  → ./knowledge/pitfalls.md
template/knowledge/unknown-unknowns.md          → ./knowledge/unknown-unknowns.md
template/knowledge/design-system.md             → ./knowledge/design-system.md
template/knowledge/packages.md                  → ./knowledge/packages.md
template/knowledge/mistakes/recent.md           → ./knowledge/mistakes/recent.md
template/knowledge/mistakes/archive/.gitkeep    → ./knowledge/mistakes/archive/.gitkeep
template/.claude/agents/mistake-logger.md       → ./.claude/agents/mistake-logger.md
template/.claude/agents/rule-promoter.md        → ./.claude/agents/rule-promoter.md
template/.claude/agents/rule-deprecator.md      → ./.claude/agents/rule-deprecator.md
template/.claude/agents/mistake-compressor.md   → ./.claude/agents/mistake-compressor.md
template/.claude/agents/session-analyzer.md     → ./.claude/agents/session-analyzer.md
template/.claude/agents/agent-synthesizer.md    → ./.claude/agents/agent-synthesizer.md
template/.claude/agents/GOVERNANCE.md           → ./.claude/agents/GOVERNANCE.md
template/.claude/settings.json                  → ./.claude/settings.json
template/.claude/hooks/check-ui-rules.sh        → ./.claude/hooks/check-ui-rules.sh
template/.claude/hooks/check-deploy-web-assets.sh → ./.claude/hooks/check-deploy-web-assets.sh
template/.claude/hooks/check-starter-version.sh → ./.claude/hooks/check-starter-version.sh
template/.claude/output-styles/fluent-korean.md → ./.claude/output-styles/fluent-korean.md
template/.claude/output-styles/LICENSE-fluent-korean.txt → ./.claude/output-styles/LICENSE-fluent-korean.txt
template/.gitattributes                         → ./.gitattributes (이미 있으면 *.sh eol=lf 줄만 append)
template/.claude/skills/<스킬>/SKILL.md          → ./.claude/skills/<스킬>/SKILL.md
                                                  (template/.claude/skills/ 아래 폴더 전부 — 목록을 하드코딩하지 말 것)
VERSION                                         → ./.claude/starter-version (설치된 스타터킷 버전 — 훅·/update-starter가 읽음)
```

Ops Loop 3종(`setup-sentry-autofix`·`setup-auto-triage`·`setup-perf-monitor`)과
`generate-web-assets`는 **파일만 설치**하고 이 시점에 실행하지 않는다.
Ops Loop 모듈은 Sentry 계정·GitHub PAT·프로덕션 URL 등 수동 개입이 필요해 준비되면 사용자가 직접
`/스킬명`으로 실행한다. `generate-web-assets`는 로고 소스가 준비됐을 때 사용자가 직접 실행한다. `update-starter`는 세션 시작 훅
(`check-starter-version.sh`)이 새 버전을 알릴 때 사용자 확인 후 실행한다 — 설치 시점에는 실행하지 않는다.

**주의**: 복사 원본은 위 목록(`template/`·`templates/`·`VERSION`)뿐이다. `/tmp/rcs` 루트의 `.claude/`·`docs/`
등 그 밖의 폴더는 **절대 복사하지 않는다** — 키트 자체를 관리하는 파일이라 프로젝트에 들어가면 안 된다.

### React 베이스 코드 설치 (package.json 존재 시 — 즉 React 프로젝트일 때)

토큰·베이스 코드를 프로젝트 `src/`로 복사한다. **기존 동명 파일이 있으면 개별 확인** 후 진행:

```
/tmp/rcs/templates/react/src/styles/tokens.css            → ./src/styles/tokens.css (H단계에서 값 치환됐으면 그 결과 사용)
/tmp/rcs/templates/react/src/lib/firebase.ts              → ./src/lib/firebase.ts   (FIREBASE_ENABLED=Y)
/tmp/rcs/templates/react/src/lib/env.ts                   → ./src/lib/env.ts
/tmp/rcs/templates/react/src/lib/query-client.ts          → ./src/lib/query-client.ts
/tmp/rcs/templates/react/src/lib/sentry.ts                → ./src/lib/sentry.ts     (Sentry 연동 시)
/tmp/rcs/templates/react/src/lib/i18n.ts                  → ./src/lib/i18n.ts
/tmp/rcs/templates/react/src/lib/motion.ts                → ./src/lib/motion.ts      (Framer Motion 프리셋)
/tmp/rcs/templates/react/src/components/Seo.tsx           → ./src/components/Seo.tsx  ({{PROJECT_NAME}} 치환)
/tmp/rcs/templates/react/public/robots.txt               → ./public/robots.txt
/tmp/rcs/templates/react/src/lib/test-auth.ts             → ./src/lib/test-auth.ts   (FIREBASE_ENABLED=Y — dev 테스트 로그인)
/tmp/rcs/templates/react/scripts/seed-test-accounts.mjs   → ./scripts/seed-test-accounts.mjs (FIREBASE_ENABLED=Y)
/tmp/rcs/templates/react/scripts/check-web-assets.mjs     → ./scripts/check-web-assets.mjs (배포 전 파비콘·OG 검사)
/tmp/rcs/templates/react/docs/TEST_ACCOUNTS.md            → ./docs/TEST_ACCOUNTS.md  (FIREBASE_ENABLED=Y)
/tmp/rcs/templates/react/docs/CORS.md                     → ./docs/CORS.md           (FIREBASE_ENABLED=Y)
/tmp/rcs/templates/firebase/cors.json                     → ./cors.json              (FIREBASE_ENABLED=Y — Storage CORS, origin 치환)
/tmp/rcs/templates/react/src/locales/ko/common.json       → ./src/locales/ko/common.json
/tmp/rcs/templates/react/src/types/i18next.d.ts           → ./src/types/i18next.d.ts
/tmp/rcs/templates/react/src/app/paths.ts                 → ./src/app/paths.ts
/tmp/rcs/templates/react/src/app/use-auth-state.ts        → ./src/app/use-auth-state.ts (FIREBASE_ENABLED=Y)
/tmp/rcs/templates/react/src/app/protected-route.tsx      → ./src/app/protected-route.tsx (FIREBASE_ENABLED=Y)
/tmp/rcs/templates/react/src/components/ui/README.md      → ./src/components/ui/README.md
/tmp/rcs/templates/react/components.json                  → ./components.json (shadcn 설정 — `shadcn init` 대신. init은 폰트·색 토큰을 덮어쓴다)
/tmp/rcs/templates/react/src/lib/utils.ts                 → ./src/lib/utils.ts
/tmp/rcs/templates/react/src/test/setup.ts                → ./src/test/setup.ts
```

설정 파일은 **example을 기준으로 기존 파일을 보강** (통째 덮어쓰기 금지 — diff 보여주고 승인):
```
templates/react/tsconfig.app.example.json   → tsconfig.app.json에 strict 플래그·paths 반영
(루트 tsconfig.json)                        → compilerOptions에 "paths": { "@/*": ["./src/*"] } 추가 (shadcn이 루트에서 별칭을 찾는다.
                                               baseUrl은 넣지 않는다 — TS 6에서 TS5101 에러, pitfalls § Vite 생태계 전환기)
templates/react/eslint.config.example.js    → eslint.config.js 기준 반영
templates/react/vite.config.example.ts      → vite.config.ts에 alias·manualChunks·test 반영
templates/react/.prettierrc.example         → .prettierrc
templates/react/.prettierignore.example     → .prettierignore (CI prettier --check가 루프 문서에 레드 내는 것 방지)
templates/react/index.html.example          → index.html에 테마 스크립트·메타·폰트 반영
templates/firebase/.gitignore.snippet       → .gitignore에 append
templates/firebase/firebase.json.example    → firebase.json 보강 (B-7에서 처리했으면 확인만)
templates/ci/react-ci.yml                   → .github/workflows/react-ci.yml ([NODE_VERSION] 치환)
templates/ci/firebase-hosting-deploy.yml    → .github/workflows/firebase-hosting-deploy.yml (배포 계획 시)
```

스택 기본 의존성 확인 — package.json에 없으면 추가 (CLAUDE.md 기술 스택과 일치):
```bash
npm install @tanstack/react-query zustand react-router react-hook-form zod @hookform/resolvers \
  react-i18next i18next lucide-react clsx tailwind-merge motion \
  radix-ui class-variance-authority tw-animate-css cn   # shadcn 컴포넌트 기반 (init 없이 add만 하면 빠진다)
npm install -D tailwindcss @tailwindcss/vite vitest @vitest/coverage-v8 jsdom @testing-library/react \
  @testing-library/jest-dom @testing-library/user-event prettier prettier-plugin-tailwindcss \
  eslint-plugin-jsx-a11y globals
npm install -D "eslint@^9" "@eslint/js@^9" "typescript-eslint@^8" \
  "eslint-plugin-react-hooks@^6" "eslint-plugin-react-refresh@^0.4"
npm install firebase        # FIREBASE_ENABLED=Y
npm install @sentry/react   # Sentry 연동 시
```
⚠️ ESLint는 **v9 라인으로 핀 고정** — 버전 미지정 시 ESLint 10 피어 충돌로 설치가 실패할 수 있다
(2026-07 파일럿 실측, pitfalls.md § Vite 생태계 전환기). 최신 Vite 템플릿은 lint 스크립트가
`oxlint`로 생성된다 — `"lint": "eslint ."`로 교체하고 oxlint는 제거해도 된다 (표준은 ESLint 9 flat,
rules.md § UI 금지 규칙들이 typescript-eslint type-checked 규칙에 의존).

**shadcn 기본 컴포넌트 추가** (설치 직후 한 번 — 첫 기능에서 확인창·토스트가 없어 막히는 것 방지):
```bash
npx shadcn@latest add button alert-dialog sonner input -y
```
그다음 `src/App.tsx` 최상단에 `import { Toaster } from "@/components/ui/sonner"` + `<Toaster />` 1개를 마운트한다.
`shadcn init`은 쓰지 않는다 — 키트의 tokens.css 폰트(Pretendard)·색을 덮어쓴다. 설정은 위에서 복사한 `components.json`이 대신한다.

**Vite 스캐폴드 기본 코드 보정** (strictTypeChecked에서 에러 나는 3곳 — 설치 시 함께 수정):
1. `src/main.tsx`: `document.getElementById('root')!` → null 가드로
   (`const root = ...; if (!root) throw new Error(...)` — `!`도 `as`도 규칙 위반)
2. `src/App.tsx`: `onClick={() => setCount(...)}` → 중괄호로 감싸기 (no-confusing-void-expression)
3. `src/main.tsx`: `import './index.css'` → `import './styles/tokens.css'` (index.css 삭제)

package.json scripts 확인 — 없으면 추가:
```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "typecheck": "tsc -b --noEmit",
    "test": "vitest",
    "format": "prettier --write .",
    "prebuild": "node scripts/check-web-assets.mjs",
    "check:web-assets": "node scripts/check-web-assets.mjs --strict",
    "seed:test": "node scripts/seed-test-accounts.mjs"
  }
}
```
(`prebuild`는 빌드 전에 파비콘·앱 아이콘·OG 누락을 **경고**만 한다 — 로고가 아직 없는 초기 개발은 막지 않는다.
배포 직전에는 `check-deploy-web-assets.sh` 훅과 배포 CI(`WEB_ASSETS_STRICT=1`)가 같은 검사로 **막는다**.
`seed:test`은 FIREBASE_ENABLED=Y일 때만 — 에뮬레이터에 명명 테스트 계정을 시드. 전화
테스트번호는 시드 불필요, 첫 로그인 시 자동 생성. 상세: `docs/TEST_ACCOUNTS.md`)

**Pretendard Variable 폰트 설치**:
```bash
mkdir -p public/fonts
# https://github.com/orioncactus/pretendard 릴리스에서 PretendardVariable.woff2 다운로드
curl -L -o public/fonts/PretendardVariable.woff2 \
  https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/woff2/PretendardVariable.woff2
```
index.html에 프리로드+@font-face 반영 (index.html.example 참조). 네트워크 불가 시
setup-checklist.md에 미완료로 남기고 시스템 폰트 폴백으로 진행.

**스모크 테스트 스캐폴딩** (Potemkin UI 탐지 — rules.md § 테스트):
```
/tmp/rcs/templates/react/e2e/smoke.spec.ts               → ./e2e/smoke.spec.ts
/tmp/rcs/templates/react/playwright.config.example.ts    → ./playwright.config.ts
```
`npm install -D @playwright/test` + `npx playwright install chromium`. package.json scripts에
`"smoke": "playwright test e2e/"` 추가. e2e/smoke.spec.ts의 ROUTES를 실제 공개 라우트로 채운다.

복사 후 `npm run format && npm run lint && npm run typecheck` 1회 실행해 문법·설정 호환 확인
(format 생략 시 CI의 `prettier --check .`가 첫 push부터 레드 — 2026-07 실제 프로젝트 실측).
아직 Vite 프로젝트 생성 전이면 이 블록을 건너뛰고 Step 5 완료 보고에 "React 프로젝트 생성 후
bootstrap의 'React 베이스 코드 설치' 블록을 다시 실행하세요"를 남긴다.

베이스 코드의 역할: 토큰(tokens.css)·인프라 단일 지점(firebase/env/query-client/sentry)·인증 가드
(protected-route)를 표준화한 것 — "브랜드 색 바꿔줘" 같은 요청이 토큰 파일 한 곳 수정으로 끝나게
하는 구조. `.claude/hooks/check-ui-rules.sh`가 이 체계를 우회한 하드코딩을 차단한다.

### 복사 시 주의

- 필요한 상위 폴더 자동 생성 (`docs/`, `knowledge/mistakes/archive/`, `.claude/agents/`,
  `src/{styles,lib,app,components/ui,locales/ko,types,test}/`, `web-assets/logo-source/`)
- `docs/navigator.md`, `plan.md`, `feature-spec.jsx`, `DESIGN.md`는 **복사 대상 아님**
  - 이미 있으면 그대로 두기
  - 없으면 Step 5에서 안내만 출력 (생성은 사용자 몫)

---

## Step 3: 플레이스홀더 치환

복사된 파일들에서 아래 플레이스홀더를 실제 값으로 치환.

### 치환 규칙

| 플레이스홀더 | 치환 값 | 주요 사용처 |
|-------------|--------|-----------|
| `{{PROJECT_NAME}}` | 프로젝트명 | CLAUDE.md 제목·본문, **src/components/Seo.tsx의 SITE_NAME** |
| `{{PROJECT_CONCEPT}}` | 제품 컨셉 | CLAUDE.md "프로젝트" 섹션 |
| `{{TONE_KEYWORDS}}` | 톤 키워드 | CLAUDE.md "톤앤매너" 섹션 |
| `{{BRAND_WORLD}}` | 세계관 설명 | CLAUDE.md "톤앤매너" 섹션 |
| `{{TODAY}}` | 오늘 날짜 | 초기 로그 메타데이터·design-system.md |
| `{{DESIGN_SYSTEM_SOURCE}}` | 디자인 소스 | design-system.md |
| `{{SPEECH_LEVEL}}` | UI 문체 (해요체/합쇼체) | CLAUDE.md "톤앤매너" 섹션 (훅 검사 9가 이 값을 읽음). **합쇼체면** `src/locales/ko/common.json`의 에러 문구를 "~습니다"체로 고쳐 쓴다(기본은 해요체) |
| `{{HOSTING_SITE}}` | Firebase Hosting 사이트 ID (없으면 "미정") | CLAUDE.md "배포 설정" |
| `{{PRODUCTION_DOMAIN}}` | 프로덕션 도메인 (없으면 "미정") | CLAUDE.md "배포 설정" |

`knowledge/rules.md § 한국어 카피`의 `{{name}}`·`{{count}}`는 i18next 보간 문법 예시다 — 플레이스홀더가 아니므로 치환하지 않는다.

### 조건부 섹션 처리

플레이스홀더 형식: `<!-- IF:FIREBASE_ENABLED -->` ~ `<!-- END -->`

**`{{FIREBASE_ENABLED}}` = N 인 경우:**
- `<!-- IF:FIREBASE_ENABLED -->` ~ `<!-- END -->` 사이 내용 **삭제** (태그 포함)

**`{{FIREBASE_ENABLED}}` = Y 인 경우:**
- 태그만 삭제, 내용은 유지

**`{{AI_ENABLED}}` = N 인 경우:**
- `<!-- IF:AI_ENABLED -->` ~ `<!-- END -->` 사이 삭제
- `src/lib/ai/` 관련 모든 언급 삭제

**`{{BRAND_WORLD}}`가 "없음" 또는 빈 문자열인 경우:**
- 톤앤매너 섹션에서 구체적 캐릭터 언급 부분을 일반적 표현으로 변경

---

## Step 4: 설치 검증

아래 항목 모두 통과해야 완료 처리:

### 파일 존재 확인
- [ ] `CLAUDE.md` 존재
- [ ] `docs/questions.md`, `docs/insights.md`, `docs/proposals.md`, `docs/setup-checklist.md` 존재
- [ ] `knowledge/INDEX.md`, `rules.md`, `pitfalls.md`, `unknown-unknowns.md`, `design-system.md`, `packages.md` 존재
- [ ] `knowledge/mistakes/recent.md` + `archive/` 폴더 존재
- [ ] `.claude/agents/` 아래 6개 에이전트 + GOVERNANCE.md 존재
- [ ] `.claude/settings.json` + `.claude/hooks/` 3종(check-ui-rules.sh·check-starter-version.sh·check-deploy-web-assets.sh) 존재
- [ ] (React 프로젝트인 경우) `scripts/check-web-assets.mjs` + package.json `prebuild`·`check:web-assets` 존재
- [ ] (React 프로젝트인 경우) `components.json` + `src/components/ui/`에 button·alert-dialog·sonner·input + App에 `<Toaster />`
      + 루트·app tsconfig 모두 `paths`(baseUrl 없음) — `npx tsc -b --noEmit` 통과
- [ ] `.claude/output-styles/fluent-korean.md` + `LICENSE-fluent-korean.txt` 존재, settings.json에
      `"outputStyle": "fluent-korean"` 존재
- [ ] `.claude/starter-version` 내용이 `/tmp/rcs/VERSION`과 동일
- [ ] `/tmp/rcs/template/.claude/skills/` 아래 스킬 폴더가 전부 `.claude/skills/`에 존재 (개수 일치)
- [ ] (React 프로젝트인 경우) `src/styles/tokens.css` + `src/lib/`(env·query-client, Firebase 시
      firebase.ts) + `src/components/ui/README.md` + i18n 3종 + `src/app/paths.ts` 존재,
      기본 의존성 + scripts(lint/typecheck/test/build) 존재, `npm run lint`·`npm run typecheck` 통과
- [ ] (Firebase 사용 시) `.env`에 VITE_FIREBASE_* 6종 + firebase.json + firestore.rules 존재

### 내용 검증
- [ ] CLAUDE.md 총 글자 수 4,000자 이하 + 200줄 이하 (공식 권장 상한)
- [ ] CLAUDE.md에 `{{` 또는 `}}` 플레이스홀더 잔존 없음
- [ ] CLAUDE.md에 `<!-- IF:` 태그 잔존 없음
- [ ] CLAUDE.md 요청 로깅 포맷에 `근본원인`/`일반화 후보` 필드 존재 (회고·규칙 승격의 근거가 됨)
- [ ] knowledge/INDEX.md에 `{{` 잔존 없음
- [ ] `.gitignore`에 `.secrets/`·`.env.local`·`.cache/`·`_workspace/` 포함
- [ ] CLAUDE.md 톤앤매너에 `문체: 해요체` 또는 `문체: 합쇼체`가 그대로 있음 (훅 검사 9가 grep으로 읽는 문자열)

### 검증 실패 시
- 실패 항목 모두 나열
- 자동 수정 시도하지 말 것
- 사용자에게 보고 후 대기

---

## Step 5: 체크리스트 대조 + 완료 보고

완료 보고 전에 먼저 `docs/setup-checklist.md`를 열어 Step 0.5에서 확인한 연동 결과(GitHub/Firebase/
Sentry/AI/Figma/디자인/스케줄/MCP)를 해당 체크박스에 반영한다 — 연동 안 된 항목은 체크하지 말고
대괄호 안에 상태를 그대로 남겨둔다(추측으로 체크하지 말 것).

그다음 **"⚡ Day 0" 섹션의 미완료 항목을 하나씩 사용자에게 브리핑**한다 — 항목마다 (a) 왜 지금 해야
하는지 한 줄, (b) 구체적으로 어디서 어떻게 하는지(콘솔 경로·명령어), (c) 사용자가 "완료"라고 하면
체크 표시. "나중에"를 선택한 항목은 남겨두면 된다 — 이 파일이 그 자체로 남은 할 일 목록이 된다.

아래 형식으로 사용자에게 출력:

```
✅ {{PROJECT_NAME}} Starter Kit 설치 완료

📁 생성된 파일:
CLAUDE.md                          (XXX자)
docs/
  questions.md                     (요청 로그)
  insights.md                      (월간 분석 결과)
  setup-checklist.md               (CLI·MCP·API 연동 현황 체크리스트)
knowledge/
  INDEX.md                         (상황별 라우터)
  rules.md                         (승격된 규칙 + React 프로덕션 초기 규칙)
  pitfalls.md                      (플랫폼 함정)
  unknown-unknowns.md              (겪기 전에 미리 아는 함정 58선)
  design-system.md                 (토큰 매핑표)
  mistakes/recent.md + archive/
.claude/agents/                    (개발팀 Loop 6종 + GOVERNANCE)
.claude/settings.json              (권한 허용목록 + 훅 2종 등록 + fluent-korean output-style 기본값)
.claude/hooks/check-ui-rules.sh    (하드코딩 색·빈 콜백·경계 위반·AI 티 카피 결정론적 차단)
.claude/hooks/check-starter-version.sh (세션 시작 시 스타터킷 새 버전 🆕 알림)
.claude/hooks/check-deploy-web-assets.sh (호스팅 배포 직전 파비콘·앱 아이콘·OG 검사 — 누락 시 배포 차단)
.claude/output-styles/fluent-korean.md (에이전트 한국어 문장 품질 — 새 세션부터 적용)
.claude/starter-version            (설치된 스타터킷 버전)
.claude/skills/
  setup-sentry-autofix/            (Ops Loop Push — 준비되면 /setup-sentry-autofix 실행)
  setup-auto-triage/               (Ops Loop Pull — 이슈·CI 실패 다이제스트)
  setup-perf-monitor/              (Ops Loop Pull — 웹바이탈·번들 예산, 첫 배포 후)
  setup-firebase-mcp/              (Firebase 라이브 조회 — 준비되면 실행)
  generate-web-assets/             (로고 준비되면 파비콘·OG 생성)
  update-starter/                  (새 버전 반영 + 변경 내역 링크 — 🆕 알림 시 실행)
src/
  styles/tokens.css                (디자인 토큰 단일 출처)
  lib/                             (firebase·env·query-client·sentry·i18n 단일 지점)
  app/paths.ts + protected-route.tsx
  components/ui/README.md          (공용 컴포넌트 카탈로그)

📋 docs/setup-checklist.md에 Step 0.5 연동 결과를 체크박스로 반영했습니다.

⚠️ 기획 문서 체크:
[docs/navigator.md / plan.md / feature-spec.jsx / DESIGN.md 존재 여부]
없는 문서는 사람이 직접 작성해야 합니다.

📝 다음 단계:
1. CLAUDE.md 검토 후 필요시 수정
2. 없는 기획 문서 작성 (있다면 건너뜀)
3. 설치 검증 테스트:
   "knowledge/INDEX.md 읽고 네가 뭘 해야 하는지 요약해봐"

🔄 스타터킷이 업데이트되면 세션 시작 시 🆕 알림이 뜹니다 → /update-starter
   (완료 시 무엇이 달라졌고 무엇을 새로 써볼 수 있는지 변경 내역 링크로 안내)
✍️ fluent-korean output-style은 새 세션부터 적용됩니다 (이 세션에는 영향 없음)

🔐 보안 체크:
- .gitignore에 .secrets/·.env.local 포함 확인
- VITE_ 접두사에 시크릿 없는지 확인 (번들 공개됨)

🗑️ 임시 파일 정리:
rm -rf /tmp/rcs
```

---

## 실패 시 롤백

> 증상별 해결법은 키트 저장소의 `docs/TROUBLESHOOTING.md`(설치 원본 `/tmp/rcs/docs/TROUBLESHOOTING.md`)를 먼저 확인한다.
> 사용자가 오류를 보고하면 그 문서에서 같은 증상을 찾아 해결책을 제시한 뒤 진행한다.

중간 단계 실패 시 아래 순서로 처리:

1. 이미 복사한 파일 목록 출력
2. `CLAUDE.md.bak` 존재하면 복원 제안
3. 사용자에게 선택 제시:
   - (a) 이어서 진행 (문제 수동 해결 후)
   - (b) 지금까지 복사한 파일 롤백
   - (c) 현재 상태 유지하고 중단
자동 롤백하지 말 것. 반드시 사용자 승인 필요.
