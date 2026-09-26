# Changelog

## v1.8.1 (2026-09-26)

### 달라진 것
- `LICENSE` 보강(여전히 초안): 등급별 좌석·외주 사용 표, 외부 개발자 계약 종료 시 사본 삭제, AI 모델 학습 데이터 사용 금지,
  업데이트 기간(구매 후 12개월 + 갱신) 조항, 환불·청약철회는 판매 페이지 정책과 전자상거래법을 따른다는 조항.
- 설치 문서·지식 문서의 사례 출처 표기를 일반화 ("실제 프로젝트 실측").
- README 개발팀 Loop 설명의 훅 개수 정정 (2종: 편집 즉시 UI 규칙 검사 · 배포 직전 웹 에셋 검사).

### 새로 써볼 수 있는 것
- **`docs/TROUBLESHOOTING.md`** — 설치·업데이트·배포가 막혔을 때 증상별 해결법(저장소 접근 404, Firebase 권한·승인
  도메인·리디렉션 오류, 훅 미동작, 배포 게이트, 새 버전 알림 미표시 등). Claude Code에게 "TROUBLESHOOTING에서 이 증상
  찾아서 해결해줘"라고 하면 된다.
- README **컨텍스트 비용** 표 — 설치 후 항상 읽히는 양(약 1만 2천 자)과 필요할 때만 읽히는 양.

### 업그레이드 시 할 일
- 없음

## v1.8.0 (2026-09-26)

### 달라진 것
- **구매 고객 전용 배포본으로 전환.** 이 키트는 구매 고객에게만 제공되며, 사용 조건은 새로 추가된 `LICENSE`를 따른다
  (재배포·재판매·공개 저장소 게시 금지).
- **Sentry AutoFix 워크플로우(`templates/ci/sentry-autofix.yml`) 보안 재설계.** Sentry DSN은 공개 값이라 누구나 가짜
  에러로 Claude에게 지시를 끼워 넣을 수 있다 — 이 경우 이전 구조에서는 Claude가 `package.json` 스크립트를 바꾼 뒤
  lint 실행 시점에 API 키와 쓰기 권한 토큰이 있는 환경에서 임의 명령이 실행될 수 있었다. 이제 세 job으로 나뉜다:
  - `fix` — Claude 분석·수정·리뷰. API 키 O · 쓰기 권한 X · Bash 도구 X (코드 실행 없음)
  - `verify` — lint/typecheck/test. 시크릿 X · 쓰기 권한 X
  - `open-pr` — 커밋·푸시·PR. 쓰기 권한 O · npm 실행 X
  - 세 job 모두 "변경은 `src/` 앱 코드만"(테스트·설정·`package.json`·심볼릭 링크·5개 초과 파일·300줄 초과 거부)을
    다시 검사하고, 하루 실행 상한(`MAX_RUNS_PER_DAY`, 기본 10)과 `--max-turns`로 비용 폭주를 막는다.
- Auto Triage 워크플로우: 체크아웃 토큰을 남기지 않고(`persist-credentials: false`), 다이제스트에서 키·토큰 형식 문자열을
  가린다.
- 프로젝트 세팅 문서의 계정·권한 안내를 특정 회사 기준에서 일반 기준(회사·법인 계정, 외주일 때의 인수인계)으로 바꿈.
- 설치 시 스킬 복사가 "`template/.claude/skills/` 아래 전부"로 바뀜 (목록 하드코딩 제거).
- `index.html` 아이콘 순서: ICO → PNG 192 → SVG. Google 검색 결과 아이콘은 SVG를 지원하지 않고 48px보다 큰 ICO/PNG를
  권장하므로 `icon-192.png`를 `rel="icon"`으로 추가하고 SVG를 맨 뒤로 옮김 (`/generate-web-assets`도 같은 순서로 연결).

### 새로 써볼 수 있는 것
- **배포 전 웹 에셋 게이트** — `scripts/check-web-assets.mjs`가 파비콘(Google 검색 결과 아이콘 기준)·apple-touch-icon·
  매니페스트 192/512·OG 이미지(https 절대 URL·1200×630)·robots.txt 크롤 허용·firebase.json 전역 noindex를 검사한다.
  - `npm run build` 전(`prebuild`)에는 경고만, `npm run check:web-assets`·배포 CI(`WEB_ASSETS_STRICT=1`)에서는 실패 시 중단.
  - 새 훅 `check-deploy-web-assets.sh`(PreToolUse)가 에이전트의 `firebase deploy`(호스팅 포함)·`hosting:channel:deploy`·
    `npm run deploy`를 검사 실패 시 막고 `/generate-web-assets`로 보낸다.
  - 배포 후 `node scripts/check-web-assets.mjs --url https://<도메인>`으로 실제 사이트를 Googlebot처럼 확인
    (배포 CI는 저장소 Variables `SITE_URL`이 있으면 자동 실행).

### 업그레이드 시 할 일
- React 프로젝트: `scripts/check-web-assets.mjs`를 복사하고 package.json에 `"prebuild": "node scripts/check-web-assets.mjs"`,
  `"check:web-assets": "node scripts/check-web-assets.mjs --strict"` 추가. `.claude/settings.json`에 PreToolUse(Bash) 훅
  `bash .claude/hooks/check-deploy-web-assets.sh` 병합. `npm run check:web-assets`가 실패하면 `/generate-web-assets` 실행.
- 배포 CI를 쓰는 프로젝트: `.github/workflows/firebase-hosting-deploy.yml`의 build 단계에 `WEB_ASSETS_STRICT: "1"`,
  배포 후 확인 단계 추가(새 템플릿 참고) + 저장소 Variables에 `SITE_URL` 등록.
- 이미 배포된 사이트에서 Google 검색 결과에 기본(지구본) 아이콘이 뜨면: 위 검사 통과 → 재배포 → Search Console URL 검사에서
  홈페이지 색인 생성 요청. 반영까지 며칠~몇 주 걸린다.
- `/setup-sentry-autofix`를 이미 실행한 프로젝트: `.github/workflows/sentry-autofix.yml`을 새 템플릿으로 **교체**한다
  (`[NODE_VERSION]`·`[BASE_BRANCH]` 다시 치환). 이전 파일은 위 공격 경로가 열려 있으므로 미루지 말 것.
- `/setup-auto-triage`를 실행한 프로젝트: `.github/workflows/auto-triage.yml`도 새 템플릿으로 교체 권장.

## v1.7.4 (2026-09-26)

### 달라진 것
- 저장소 이름 변경: `react-agent-starter` → **`fine-harness-react-kit`**. 새 버전 알림 훅·`/update-starter`가
  가리키는 원격 저장소(`FineHourTeam/fine-harness-react-kit`)와 알림·완료 보고에 표시되는 이름이 바뀜.
- 스킬 이름(`/update-starter`)·버전 파일(`.claude/starter-version`)·훅 파일명은 그대로 유지 (호환성).

### 새로 써볼 수 있는 것
- 없음

### 업그레이드 시 할 일
- 없음 — GitHub가 옛 이름의 git·API 요청을 새 이름으로 넘겨 주므로 v1.7.3 이하 설치본도 계속 알림을 받고, 이번
  업데이트로 훅·스킬이 통째로 교체되면서 새 이름으로 바뀐다. 로컬에 이 저장소를 클론해 두었다면
  `git remote set-url origin https://github.com/FineHourTeam/fine-harness-react-kit.git` 권장.

## v1.7.3 (2026-09-23)

### 달라진 것
- 알림·완료 보고의 링크를 `업데이트 내역 확인하기 > RELEASE_NOTES 링크` **한 줄**로 통일 (쉬운 설명/기술 상세 두 링크 제거).

### 새로 써볼 수 있는 것
- 없음

### 업그레이드 시 할 일
- 없음

## v1.7.2 (2026-09-23)

### 달라진 것
- 새 버전 알림(훅)과 `/update-starter` 완료 보고가 **`RELEASE_NOTES.md`(비전공자용 쉬운 설명)를 먼저 링크**하고, 기술 상세는
  CHANGELOG 링크로 뒤에 붙인다. 스킬은 반영 전에 RELEASE_NOTES의 해당 minor 항목을 요약 없이 그대로 보여준다.
- 루트 CLAUDE.md 릴리스 규칙에 RELEASE_NOTES 작성 형식(minor 단위 헤딩·고정 소제목·스킬 항목 형식) 추가.

### 새로 써볼 수 있는 것
- **`RELEASE_NOTES.md`** — 개발을 모르는 사람도 읽을 수 있는 업데이트 안내. 알림 링크를 누르면 이 문서가 열린다.

### 업그레이드 시 할 일
- 없음 (훅·스킬은 통째로 교체되는 파일)

## v1.7.1 (2026-09-23)

### 달라진 것
- 버전 확인이 raw URL 대신 **`gh api`** 로 바뀜 — 이 저장소는 비공개라 raw.githubusercontent.com이 404를 내서 v1.7.0의
  세션 시작 훅·`/update-starter`가 새 버전을 감지하지 못했다. gh CLI는 bootstrap A-1 필수 도구이므로 추가 설치 없음.
  gh가 없는 환경에서만 raw URL(공개 저장소용) 폴백.

### 새로 써볼 수 있는 것
- 없음 (v1.7.0 기능이 실제로 동작하게 된 것)

### 업그레이드 시 할 일
- 없음 — `.claude/hooks/check-starter-version.sh`와 `update-starter/SKILL.md`는 통째로 교체되는 파일.
  단, v1.7.0을 수동으로 올린 프로젝트가 있다면 `gh auth status`로 로그인 상태만 확인.

## v1.7.0 (2026-09-22)

### 달라진 것
- **`.claude/settings.json`에 `"outputStyle": "fluent-korean"` 기본값** — 에이전트가 사용자에게 말하는 한국어가
  [fluent-korean](https://github.com/snflkd/fluent-korean) output-style(MIT 사본 `.claude/output-styles/`)을 따른다.
  조사·어미 생략, 명사 나열, 비유어 치환이 줄고 문장이 조금 길어진다(토큰 소폭 증가). 새 세션부터 적용, 끄려면 키 삭제.
  코드 안 문자열·커밋 메시지는 이 스타일의 적용 대상이 아니다(도구 자체 조항).
- **`check-ui-rules.sh` 검사 9 추가** — src/·`src/locales/*.json` 편집 시 한국어 카피 AI 티 5종(해요체 프로젝트의
  합쇼체 어미 · 과잉 경어 "~하실 수/께서/시겠습니까" · "성공적으로" · 당신/여러분/혁신적인 · 변수 뒤 조사 하드코딩
  `${name}이`)을 exit 2로 차단. 주석 줄·테스트 파일 제외. 문체 검사는 CLAUDE.md의 `문체: 해요체`를 읽어 켜진다.
- **`tokens.css` body에 `word-break: keep-all` + `overflow-wrap: break-word`** — 한국어 어절 중간 줄바꿈 방지.
- bootstrap: Step 0-B 질문 8(UI 문체 해요체/합쇼체 → `{{SPEECH_LEVEL}}`), Step 0.5-K(im-not-ai 전역 설치 확인, 블로커
  아님), Step 2 복사 목록에 output-style 2파일·훅·스킬·`VERSION → .claude/starter-version`, Step 4 검증 항목 추가.
- `template/CLAUDE.md` 톤앤매너에 `문체:` 줄 추가 + 자기비판 항목에 "한국어 카피" 포함 (4,000자 예산 안에서 다른 줄 압축).
- CHANGELOG 항목 형식이 "달라진 것 / 새로 써볼 수 있는 것 / 업그레이드 시 할 일" 고정 소제목으로 바뀜 —
  `/update-starter`가 이 소제목을 파싱해 보여준다 (루트 CLAUDE.md § 버전·릴리스 노트).

### 새로 써볼 수 있는 것
- **세션 시작 🆕 알림 + `/update-starter`** — 스타터킷 새 버전이 나오면 세션 시작 시 훅(`check-starter-version.sh`,
  하루 1회 원격 `VERSION` 확인)이 알리고 에이전트가 "지금 업데이트할까요?"를 묻는다. 수락하면 스킬이 이 파일의
  해당 버전 항목을 먼저 보여준 뒤 파일별 정책(교체 / 신규만 추가 / 수동 병합 / 보존)대로 반영하고, 완료 보고에
  버전별 변경 내역 링크와 새로 써볼 수 있는 기능을 붙인다. 언제: 🆕 알림에 "응" 또는 `/update-starter`.
- **`knowledge/rules.md § 한국어 카피`** — 제품 안 한국어(UI·토스트·에러·빈 화면·푸시·이메일·랜딩·챗봇)의 서비스
  특화 AI 티 블랙리스트 + ❌/✅ 대조쌍. 2026-09 웹 리서치(토스 8원칙·앱인토스, 당근 SEED 국제화, 배민·구름·모비인사이드,
  KatFish ACL 2025, 아이보스 실험) 기반. 언제: UI 문구를 쓰거나 리뷰할 때 자기비판 체크리스트로
  (INDEX § UI 화면 구현 5 · § 작업 완료 후 3).
- **fluent-korean output-style** — 에이전트 보고·질문의 한국어 품질. 언제: 자동(설정 기본값). 문체가 안 지켜지는 긴
  산출물은 `.claude/output-styles/fluent-korean.md` 본문을 프롬프트에 붙여 스킬처럼 써도 된다(도구 README 권장).
- **im-not-ai `/humanize-scan` 연계** — 300자+ 산문 카피(랜딩·온보딩·이메일·공지)의 AI 티 점검이 INDEX "작업 완료 후"
  3번에 들어감. 사용자 전역 설치 필요: `/plugin marketplace add epoko77-ai/im-not-ai` →
  `/plugin install humanize-korean@im-not-ai` (setup-checklist § 한국어 품질 도구). 작업 폴더 `_workspace/`는 .gitignore.

### 업그레이드 시 할 일
1. `CLAUDE.md § 제품 톤앤매너`에 `문체: 해요체` 또는 `문체: 합쇼체` 한 줄 추가 — 훅 검사 9의 문체 검사가 이 문자열로
   켜진다 (없으면 문체 검사만 건너뜀, 나머지 4종은 동작).
2. `.claude/settings.json`에 `"outputStyle": "fluent-korean"`과 `SessionStart` 훅 항목을 병합 (스킬이 diff 제시).
3. `.gitignore`에 `_workspace/` 추가.
4. 기존 UI 문자열에 "성공적으로"·"~하실 수" 등이 있으면 그 파일을 다음에 편집할 때 훅이 막는다 — 미리
   `grep -rnE '성공적으로|하실 수|께서|시겠습니까|당신|여러분|혁신적인' src/`로 목록을 뽑아 한 번에 고치는 것을 권장.
5. (선택) im-not-ai 전역 설치 — 위 명령 2줄.

파괴적 변경 없음 (훅 검사 9는 편집 시점 차단이라 기존 코드를 깨지 않지만, 레거시 문구가 있는 파일 편집은 막힐 수 있음).

## v1.6.1 (2026-07-28)

### Firebase Auth·Storage 초기화 CLI화 (실제 프로젝트 파일럿 실측)

bootstrap B-5의 콘솔 수동 단계 2건(Authentication·Storage "시작하기")을 REST API로 대체 —
사용자 개입 없이 에이전트가 직접 실행 가능.

- Authentication 초기화: `identitytoolkit v2 identityPlatform:initializeAuth` POST
- Storage 기본 버킷: `firebasestorage v1beta projects/<id>/defaultBucket` POST (리전 지정)
- 두 호출 모두 `x-goog-user-project: <PROJECT_ID>` 헤더 필수 (없으면 403 SERVICE_DISABLED)
- 콘솔에 남는 것은 **소셜(OAuth) 로그인 공급자 활성화 1클릭뿐** — OAuth 클라이언트 자동 생성이
  공개 API에 없음 (`defaultSupportedIdpConfigs`가 client_id 요구). 표·안내 문구 갱신.

- **신규 `templates/react/.prettierignore.example`**: CI의 `prettier --check .`가 루프 문서
  (CLAUDE.md·docs/·knowledge/·.claude/)까지 검사해 첫 push부터 레드가 나던 문제 차단.
  bootstrap 복사 목록에 추가 + 설치 검증에 `npm run format` 1회 선행 명시.

- **bootstrap 의존성에 `@vitest/coverage-v8` 추가**: react-ci.yml이 `npm run test -- --run
  --coverage`를 돌리는데 설치 목록에 커버리지 프로바이더가 없어 CI Test 단계가
  MISSING DEPENDENCY로 실패하던 문제 (실제 프로젝트 실측). coverage/ 산출물은 .gitignore에 선반영할 것.

- **authorizedDomains PATCH 단계 추가**: initializeAuth(API)는 콘솔과 달리 기본 승인 도메인을
  등록하지 않음 — localhost 누락으로 소셜 로그인 unauthorized-domain 발생 (실제 프로젝트 실측).
- **redirect_uri_mismatch 함정 문서화**: 접미사 붙은 기본 사이트 프로젝트에서 자동 생성 OAuth
  클라이언트에 실제 authDomain 핸들러 URI가 빠질 수 있음 — 콘솔 수정 절차 + authDomain을
  실접속 Hosting 도메인으로 권장.

- **undelete 복구 프로젝트의 (default) Firestore 좀비 상태 경고**: 복구 후 하루 뒤 원 삭제
  파이프라인이 (default) DB를 서빙 불가로 만든 사례 (실제 프로젝트 실측 — list 보임/서빙 불가/삭제·재생성
  불가). 복구 프로젝트는 named DB 사용 지침 추가.

파괴적 변경 없음 (절차 개선).

## v1.6.0 (2026-07-14)

### CORS 설정 (Firebase 웹앱 — 2026 리서치 반영)

React+Firebase 웹앱에서 CORS가 막히는 4곳(Storage 파일 fetch·앱↔Functions·외부 API·로컬 dev)의
해법을 단일 출처로 정리. 원칙 = **가능하면 같은 오리진으로 피하고, 불가피한 Storage만 버킷 CORS로 연다.**

- `docs/CORS.md` (신규 단일 출처) — 결정 트리 + ① Storage 버킷 CORS(`gcloud storage buckets update
  --cors-file`, 현행 명령) ② Functions v2 내장 `cors` 옵션(cors npm 불필요)·onCall 자동 ③ Hosting
  `/api/**` rewrite로 CORS 회피(권장) ④ Vite dev proxy + App Check preflight 주의.
- `templates/firebase/cors.json` (신규) — Storage CORS 설정(최상위 배열·실도메인 origin·`*` 금지).
- `firebase.json.example` — `/api/**` → 함수 rewrite(v2 객체형, SPA catch-all 앞) 추가.
- `vite.config.example.ts` — dev proxy 예시(주석) 추가.
- `rules.md § Firebase CORS` + `unknown-unknowns` #11 확장(다운로드 URL fetch/canvas CORS) +
  setup-checklist + REACT_FIREBASE_SETUP 6단계 + bootstrap 복사.
- 2026 반영: gsutil→gcloud storage 권장 전환, 버킷 접미사 `firebasestorage.app`, Functions 2세대=
  Cloud Run functions(dual URL), App Check 헤더 preflight.

파괴적 변경 없음 (전부 추가형).

## v1.5.0 (2026-07-14)

### 컴포넌트·패키지 우선 시스템 (2026 리서치 반영)

"바퀴를 다시 발명하지 말고 검증된 컴포넌트·패키지를 조합" 원칙을 명문화·체계화. 웹 리서치로
카테고리별 표준 패키지·shadcn 카탈로그·안티패턴·채택 정책을 정리해 반영.

- `knowledge/packages.md` (신규) — 리치포(reach-for) 맵 단일 출처: 스택 확정 표(대체 라이브러리 금지),
  shadcn 경유 무료 획득(sonner·cmdk·embla·recharts·vaul·input-otp·react-day-picker·date-fns·cva),
  필요시 추가(TanStack Table/Virtual·dnd-kit·react-dropzone·tiptap·react-markdown+dompurify·
  libphonenumber-js·ts-pattern), shadcn 카탈로그 전체, 안티패턴 표(❌손수/✅대신).
- `rules.md § 컴포넌트·패키지 우선` — 원칙 + 4단계 채택 정책(이미 커버되는가 STOP → 안정성 검증 →
  번들 예산 → 사람 승인 에스컬레이션).
- `CLAUDE.md` 절대규칙에 "컴포넌트·패키지 우선" 명시 (기존 UI 줄 승격). INDEX.md 새 기능·UI 경로에
  packages.md 라우팅 추가.
- **스택 문서 갱신 3건** (2026 리서치): shadcn 기본이 Base UI로 전환(단 Radix 유지·무마이그레이션 —
  우리는 안정 우선 `shadcn init -b radix`) / Radix 단일 `radix-ui` 패키지 통합 / **Framer Motion →
  `motion`(`motion/react`) 전환** — 의존성·motion.ts·rules 갱신, 파일럿에서 motion 12.42.2
  typecheck/lint 검증.

파괴적 변경: motion 패키지명 변경(framer-motion → motion). 신규 설치는 영향 없음, 기존 설치는
`npm i motion && npm rm framer-motion` + import를 `motion/react`로 (framer-motion도 re-export로 계속 동작).

## v1.4.0 (2026-07-14)

### 디자인 3종 조합(Framer Motion 채택) + SEO 갭 채우기

**Framer Motion 기본 채택 (웹 전용 — flutter 미이식)**
- 디자인 기본 스택 = **Tailwind v4 + shadcn/ui + Framer Motion** 3종으로 명문화 (CLAUDE.md·README).
- `src/lib/motion.ts` — 표준 프리셋(easing·duration·transitions + fadeIn/slideUp/scaleIn/stagger
  variants). 화면마다 즉석 duration/easing 금지, 프리셋만 재사용 (디자인 토큰과 같은 원리).
- `rules.md § 모션` — 역할 분담(shadcn/Radix=컴포넌트 진입퇴장 CSS, Framer=커스텀·오케스트레이션),
  절제 원칙(과한 애니메이션=AI 티, 기존 § 금지 비주얼과 한 세트), `useReducedMotion` 접근성 필수.
- bootstrap 의존성에 `framer-motion` 추가. 파일럿에서 v12.42.2 설치·typecheck·lint 통과 확인.

**SEO 갭 채우기 (favicon~SEO 완결)**
- favicon/OG/PWA/manifest는 이미 완비(index.html.example + generate-web-assets)였으나 **라우트별 동적
  SEO와 robots.txt가 없던 갭**을 채움.
- `src/components/Seo.tsx` — React 19 네이티브 metadata(react-helmet 불필요). 라우트 최상단
  `<Seo title description image noindex />` 한 줄로 title/description/OG 세팅, 인증뒤 화면 noindex.
  파일럿에서 렌더 테스트로 head 호이스트(document.title·meta·og) 실동작 검증.
- `public/robots.txt` — 프로덕션 기본 + 스테이징 `Disallow: /` 가이드.
- `rules.md § SEO` + setup-checklist(웹 에셋·SEO) + bootstrap(복사·{{PROJECT_NAME}} 치환).

파괴적 변경 없음 (전부 추가형).

## v1.3.0 (2026-07-14)

### 구현 완결성 원칙 + 테스트 계정 규약

**구현 완결성 (프로덕션 기준)**
- `CLAUDE.md` 절대규칙 + `rules.md § 구현 완결성` 신설 — 이 스타터의 존재 이유(프로토타입 아닌
  프로덕션)를 명시 원칙으로. 기능은 정상·로딩·에러·빈 상태·엣지까지 구현해야 "완료". 목업/스텁/TODO를
  실경로에 남기기 금지, 부분 구현은 명시 지시 시만·미구현은 보고. 결정론 백스톱은 빈 콜백 훅 + e2e 스모크.

**테스트 계정 규약 (dev+에뮬레이터 전용)**
- `src/lib/test-auth.ts` — 전화 `010########` 전체 범위/OTP `123456`, 이메일 `@test.local`/고정 비번.
  실 SMS 없이 에뮬레이터 합성 계정으로 세션 생성 (Firebase 콘솔 테스트번호 10개 상한 우회).
  **프로덕션 하드 차단**: `import.meta.env.DEV && VITE_USE_EMULATORS` 이중 가드 — 진리표 검증 완료,
  프로덕션은 어떤 경우에도 비활성(고정 OTP 백도어 방지).
- `scripts/seed-test-accounts.mjs` — 에뮬레이터에 admin/user/user2 @test.local 시드 (REST, 무의존성,
  멱등). 실 에뮬레이터로 시드·로그인·합성계정 생성 end-to-end 검증 완료.
- `docs/TEST_ACCOUNTS.md` — QA·심사 리뷰어용 단일 출처(로그인 UI 배선 예시 + 프로덕션 QA는 콘솔
  테스트번호 ≤10 등록 안내). `rules.md § 테스트 계정` + setup-checklist + bootstrap + `npm run seed:test`.

파괴적 변경 없음 (전부 추가형).

## v1.2.0 (2026-07-14)

### AI 웹빌더(v0/Lovable/Bolt/Replit) 노하우 조사 → 검증 후 12건 반영

멀티에이전트 워크플로우(리서치 6각도 → 갭 분석 → 후보별 회의적 검증)로 AI 웹빌더들의 유출 시스템
프롬프트·공식 문서를 조사, 우리 레포에 없으면서 "안정 우선·토큰 강제·사람 승인" 철학에 맞는 12건만
반영. 검증에서 이미 레포에 구현된 3개 핵심 사상(시맨틱 토큰+결정론적 훅, 컨텍스트 2단 라우팅,
역메타프롬프팅)은 "검증된 설계"로 확인.

**디자인 정량 규칙 (v0 검증)**
- `rules.md § 디자인`: 팔레트 3~5색 상한(브랜드1+뉴트럴1~2+액센트0~2, 상태색 예외) · AI 기본색
  (보라·인디고·기본 블루) 주조색 금지 · 콘트라스트 페어 강제(bg 지정 시 text-foreground 필수) ·
  AI슬롭 블랙리스트(그라디언트 기본금지·장식 blob 금지·이모지 아이콘 금지·일러스트 손제작 금지)
- `rules.md § UI`: 레이아웃 서열(Flexbox>Grid>absolute, 모바일 퍼스트) · 본문 행간 1.4~1.6
- `tokens.css`: 기본 --primary를 보라(blue-600)에서 **무채색 플레이스홀더로 교체** — 소스 '없음'
  프로젝트가 "AI 티 나는 보라 앱"으로 시작하던 문제 제거. bootstrap H단계에 브랜드색 질문 필수화

**결정론적 훅 확장**
- `check-ui-rules.sh` 검사 8 추가: 간격/라운드/섀도우 arbitrary value(`p-[13px]`·`rounded-[5px]`·
  `shadow-[...]`) 차단 — 기존엔 색·폰트만 막아 design-system.md의 "훅이 차단" 문구가 과장이던 것을
  문서-훅 정합까지 복원. 좌측 경계 가드로 `top-[..]` 오탐 방지 (테스트 통과)

**프로세스 (Lovable/Replit/Bolt 검증)**
- `CLAUDE.md`: 에러 수정 루프 이탈 프로토콜(2회 실패→중단·근본원인·다른 접근 제안, doom loop 차단)
  · 스코프 잠금(Medium+ 착수 전 "변경 파일+안 건드릴 것" 선언) · 자기비판에 범위 이탈 체크 추가
- `INDEX.md`: 디자인 브리프 게이트(모호한 UI 요청은 백지 질문 대신 브리프 초안 제시→승인→구속력
  스펙) · 버그 경로에 doom loop 프로토콜 상세
- `rule-promoter.md`: 승격 규칙에 대조쌍(❌/✅) 필수화 — 추상 규칙의 행동 고정력 강화 (3사 공통 골격)

**검증 루프 (Replit/Factory 검증)**
- `e2e/smoke.spec.ts` + `playwright.config.example.ts`: Potemkin UI(렌더는 되나 미연결) 탐지 —
  공개 라우트 로드+콘솔 에러 0+#root 비어있지 않음 검사, 핵심 인터랙션 스모크. react-ci.yml에
  smoke 잡 추가(build→preview→playwright)
- `sentry-autofix.yml`: 리뷰 게이트에 '수사관 프레이밍'(옹호자 아님) + 3단 판정
  (CONFIRMED/REFUTED/INCONCLUSIVE, CONFIRMED만 PR 생성) — 자기 코드 옹호 편향 차단

파괴적 변경: tokens.css 기본 primary 색 변경(기존 설치 프로젝트는 이미 브랜드색으로 치환했을
것이므로 영향 없음). 나머지는 전부 규칙·문서·훅 추가형.

## v1.1.1 (2026-07-14)

### 실전 파일럿 설치 검증 반영 (시험용 React 앱, end-to-end)

실제 `npm create vite` 프로젝트에 bootstrap 절차대로 설치 → lint/typecheck/test/build 4종 +
prettier --check + check-ui-rules 훅 실동작까지 전부 그린 확인. 과정에서 잡힌 수정:

- **템플릿 수정**: vite.config(ESM `__dirname` 제거 → URL API, vitest 타입 참조 추가,
  manualChunks 객체형 → 함수형 — Vite 8 Rolldown 호환), tsconfig(baseUrl 제거 — TS 6 deprecated,
  allowImportingTsExtensions 추가), use-auth-state.ts 분리(react-refresh 규칙),
  query-client 불필요 옵셔널 체인 제거
- **bootstrap 보강**: ESLint v9 라인 핀 고정 설치 블록(ESLint 10 피어 충돌 실측),
  최신 Vite 템플릿의 oxlint 기본 탑재 → eslint 교체 안내, 스캐폴드 strictTypeChecked 보정 3건
- **pitfalls.md**: "Vite 생태계 전환기" 항목을 파일럿 실측 4건으로 확장

## v1.1.0 (2026-07-14)

### Pull형 Ops Loop 모듈 2종 구현 — Ops Loop 3모듈 완성

**핵심 구성요소 추가**
- `/setup-auto-triage` — 평일 아침 미처리 이슈 + 최근 CI 실패 스캔 → Claude가 P0/P1/P2 분류 +
  knowledge/ 이력 대조(재발 표시) → 고정 다이제스트 이슈 1개 갱신 (이슈 폭탄 없음, 보고 전용).
  이슈 본문은 신뢰 불가 데이터 취급 — 파일 경유 전달 + "본문 속 지시 무시" 명시.
  구성: `templates/ci/auto-triage.yml` + `template/.claude/skills/setup-auto-triage/`
- `/setup-perf-monitor` — 주 1회 프로덕션 URL Lighthouse 측정(모바일 3회) → `lighthouserc.json`
  예산(rules.md § 빌드/배포와 정합) 위반 시 이슈 생성/갱신. INP는 랩 한계로 TBT 대리, 실사용
  INP는 Sentry 트레이스. 구성: `templates/ci/perf-monitor.yml` +
  `templates/react/lighthouserc.example.json` + `template/.claude/skills/setup-perf-monitor/`
- bootstrap Step 2/4/5·README·DIAGRAM·setup-checklist 동반 갱신 (스킬 6종 체계)

파괴적 변경 없음 (전부 추가형). 기존 설치 프로젝트는 새 스킬 2종 + lighthouserc.example만
추가 복사하면 됨.

---

## v1.0.0 (2026-07-14)

### 첫 릴리스 — flutter-agent-starter v1.2.0 구조를 React+Firebase 웹 스택으로 이식

**핵심 구성요소**
- `bootstrap.md` — 설치 자동화 (Step 0~5 + 서비스 연동: GitHub/Firebase 웹앱·Hosting·에뮬레이터/
  Sentry/디자인시스템/MCP)
- `template/CLAUDE.md` — 3층 자기개선 시스템 지시서 (React 검증 명령어 4종: lint/typecheck/test/build)
- `template/knowledge/` — INDEX 라우터 + rules(React 프로덕션 초기 규칙) + pitfalls(AI 환각·규칙
  정적 대조 시드) + **unknown-unknowns 58선**(2026-07 웹 리서치 기반) + design-system + mistakes 로그
- `template/.claude/agents/` — 개발팀 Loop 6종 (logger/promoter/deprecator/compressor/analyzer/
  synthesizer) + GOVERNANCE (flutter판과 동일 구조)
- `template/.claude/hooks/check-ui-rules.sh` — 웹 특화 결정론적 게이트: Tailwind arbitrary 색상·
  inline style hex·빈 콜백·alert/confirm·12px 미만 폰트·dangerouslySetInnerHTML·features 간 직접
  import 차단
- `template/.claude/skills/` — setup-sentry-autofix(Ops Loop Push) / setup-firebase-mcp /
  generate-web-assets(파비콘·PWA·OG)
- `templates/react/` — tokens.css(Tailwind v4 CSS-first, OKLCH, 다크 쌍) + lib 단일 지점 5종
  (firebase/env/query-client/sentry/i18n) + 인증 가드 + 설정 example 6종(tsconfig strict+/
  ESLint 9 flat/vite/prettier/index.html) + ui 카탈로그 README
- `templates/ci/` — react-ci.yml / firebase-hosting-deploy.yml(PR preview 채널) / sentry-autofix.yml
- `templates/firebase/` — sentry-to-github-function.js(HMAC 서명 검증 브릿지) /
  firebase.json.example(SPA rewrite·캐시·CSP·보안 헤더) / .gitignore.snippet

**flutter판 대비 주요 설계 차이**
- Ops Loop Push 소스: Crashlytics(웹 미지원) → **Sentry 웹훅** (Internal Integration + HMAC 서명 검증)
- AutoFix에 **기계 게이트 추가**: 리뷰 게이트 앞에 lint/typecheck/test 실행 — flutter판 백로그
  항목을 처음부터 내장
- 스토어 리뷰 모니터링(계획) → **성능 회귀 모니터링(웹바이탈)** 으로 대체
- 스토어 에셋 → **웹 에셋**(파비콘·PWA·OG) + 도메인/SEO 체크리스트
- AI API 키 정책 강화: 클라이언트 `.env(VITE_)` 등록 선택지 자체를 금지 (번들 평문 노출) —
  Cloud Functions 시크릿만

---

## 업그레이드 가이드

> 이 레포를 프로젝트에 **설치(bootstrap)**한 뒤, 레포 자체가 새 버전으로 업데이트되면 아래 방법으로
> 기존 프로젝트에 반영합니다.

### 자동 (v1.7.0+ 설치본 — 기본 경로)

세션 시작 훅(`.claude/hooks/check-starter-version.sh`)이 하루 1회 원격 `VERSION`을 `.claude/starter-version`과
비교해 새 버전이 있으면 🆕 알림을 띄우고, 에이전트가 "지금 업데이트할까요?"를 한 번 묻는다. 수락하면 `/update-starter`가:

1. 이 파일에서 설치 버전 초과 ~ 최신 버전의 항목("달라진 것 / 새로 써볼 수 있는 것 / 업그레이드 시 할 일")을 먼저 보여주고
2. 파일별 정책(`template/.claude/skills/update-starter/SKILL.md` § 4 — **단일 출처**: 에이전트·훅·output-style은 통째로
   교체, 스킬은 신규만 추가, CLAUDE.md·INDEX·pitfalls 등은 diff 제시 후 수동 병합, rules.md·mistakes·tokens.css는 보존)대로
   반영한 뒤
3. 각 버전의 "업그레이드 시 할 일"을 수행하고, 완료 보고에 버전별 변경 내역 링크(이 파일의 앵커) + 새로 써볼 수 있는
   기능을 붙인다. `.claude/starter-version`은 모든 단계가 끝난 뒤에만 갱신.

### 수동 (v1.7.0 이전 설치본 · 네트워크 없음 · 훅 미설치)

v1.7.0 이전 설치본은 아래를 한 번 실행하면(`.claude/starter-version`·훅·스킬이 생김) 그다음부터 자동 경로를 탄다.

```bash
cd /tmp && git clone --depth 1 https://github.com/FineHourTeam/fine-harness-react-kit.git rcs-latest
cd <프로젝트 루트>

# 버전 스탬프 + 알림 훅 + 업데이트 스킬 + output-style (전부 공용 파일 — 통째로 복사)
mkdir -p .claude/hooks .claude/skills .claude/output-styles
cp /tmp/rcs-latest/VERSION .claude/starter-version
cp /tmp/rcs-latest/template/.claude/hooks/*.sh .claude/hooks/
cp -r /tmp/rcs-latest/template/.claude/skills/update-starter .claude/skills/
cp /tmp/rcs-latest/template/.claude/output-styles/* .claude/output-styles/
cp /tmp/rcs-latest/template/.claude/agents/*.md .claude/agents/     # GOVERNANCE.md는 diff로 수동 병합

# settings.json — outputStyle 키와 SessionStart 훅 항목을 기존 파일에 병합 (덮어쓰지 말 것)
diff /tmp/rcs-latest/template/.claude/settings.json .claude/settings.json

# 수동 병합 대상 (프로젝트 값 보존)
diff /tmp/rcs-latest/template/CLAUDE.md ./CLAUDE.md
diff /tmp/rcs-latest/template/knowledge/INDEX.md ./knowledge/INDEX.md

rm -rf /tmp/rcs-latest
```

그다음 이 파일의 해당 버전 "업그레이드 시 할 일"을 순서대로 수행한다.

### 파괴적 변경 이력

v1.0.0: 초기 릴리스 (파괴적 변경 없음)
v1.7.0: 없음 — 훅 검사 9는 편집 시점 차단(기존 코드 무영향), outputStyle은 설정 한 줄로 해제 가능
