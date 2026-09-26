# 설치·업데이트 문제 해결

> 설치(`bootstrap.md`)나 업데이트(`/update-starter`) 중에 막혔을 때 먼저 보는 문서입니다.
> 증상으로 찾으세요. Claude Code에게 "docs/TROUBLESHOOTING.md에서 이 증상 찾아서 해결해줘"라고 해도 됩니다.
> 여기에 없는 문제는 구매 시 안내받은 지원 채널로 문의하세요 — 에러 메시지 원문과 어느 단계였는지를 함께 보내 주시면
> 가장 빨리 해결됩니다.

---

## 1. 설치 시작 전

### `git clone`이 `Repository not found` / 404로 실패한다
- 저장소 초대를 **수락**했는지 확인하세요 — GitHub 알림 또는 초대 메일에서 Accept를 눌러야 접근됩니다.
- 초대받은 GitHub 계정과 지금 로그인한 계정이 같은지 확인: `gh auth status`
- `gh auth setup-git`을 한 번 실행하면 git이 gh 로그인 정보를 씁니다.

### `gh` 명령이 없다 / 로그인이 안 돼 있다
- 설치: Windows `winget install GitHub.cli` · macOS `brew install gh`
- 로그인: `gh auth login` → 브라우저 인증까지 마친 뒤 설치를 이어서 진행

---

## 2. Firebase 연동 (bootstrap Step 0.5-B)

### 권한 오류(`403`·`PERMISSION_DENIED`)가 계속 난다
- `firebase login:list`와 `gcloud auth list`의 계정이 **같은지** 확인하세요. 두 CLI 계정이 다르면 대부분 이 오류가 납니다.
- 프로젝트도 맞추세요: `firebase use <프로젝트ID>` + `gcloud config set project <프로젝트ID>`
- 회사 프로젝트라면 개인 계정이 아닌 회사·법인 계정으로 로그인하는 것을 권장합니다 (담당자가 바뀌어도 소유권이 남도록).

### Auth·Storage 초기화에서 `403 SERVICE_DISABLED`
- 요청에 `x-goog-user-project: <프로젝트ID>` 헤더가 빠진 경우입니다. bootstrap의 명령을 그대로 쓰면 들어가 있습니다.
- 그래도 나면 `gcloud services enable identitytoolkit.googleapis.com firebasestorage.googleapis.com` 후 재시도.

### 소셜 로그인에서 `auth/unauthorized-domain`
- CLI로 Auth를 초기화하면 콘솔과 달리 `localhost`가 승인 도메인에 자동으로 들어가지 않습니다.
- bootstrap B-5의 "승인 도메인 등록" 명령을 실행하거나, 콘솔 → Authentication → 설정 → 승인된 도메인에 추가하세요.

### Google 로그인에서 `400 redirect_uri_mismatch`
- GCP 콘솔 → API 및 서비스 → 사용자 인증 정보 → 자동 생성된 OAuth 클라이언트의 "승인된 리디렉션 URI"에
  `https://<실제 authDomain>/__/auth/handler`를 추가하세요. (공개 API가 없어 콘솔에서 직접 해야 합니다.)

### Firestore가 `Cannot serve requests because the database was deleted`
- 삭제 후 복구(undelete)한 프로젝트의 `(default)` DB에서 생깁니다. 이름 있는 DB를 새로 만들어 쓰세요 —
  bootstrap B-5의 "named DB" 안내 참고.

### Cloud Functions·AI 기능 배포가 결제 관련 오류로 실패한다
- Firebase **Blaze(종량제) 플랜**이 필요합니다. 콘솔 → 프로젝트 설정 → 사용량 및 결제에서 전환하세요.

---

## 3. 설치 직후

### Firebase MCP 도구가 안 보인다
- `.mcp.json` 등록 후에는 **Claude Code를 새로 시작**해야 적용됩니다.
- 나중에 따로 등록하려면 `/setup-firebase-mcp`.

### 훅이 동작하지 않는다 (편집 검사·배포 전 검사·새 버전 알림)
- Windows는 Git Bash 등 `bash`가 필요합니다: `bash --version`
- 줄바꿈이 CRLF로 바뀌면 스크립트가 깨집니다. `.gitattributes`에 `*.sh text eol=lf`가 있는지 확인하고,
  이미 깨졌다면 `git add --renormalize . && git checkout -- .claude/hooks`
- `.claude/settings.json`의 `hooks` 항목이 있는지 확인하세요.

### 첫 push부터 CI의 `prettier --check`가 실패한다
- 설치 직후 `npm run format`을 한 번 실행하고 커밋하세요.

### 스킬 목록에 키트 스킬이 없다
- `.claude/skills/` 아래 폴더가 있는지 확인하고, 없으면 설치 원본의 `template/.claude/skills/`를 다시 복사하세요.

---

## 4. 배포

### `firebase deploy`가 "배포 전 웹 에셋 검사 실패"로 막힌다
- 파비콘·앱 아이콘·링크 공유 이미지가 빠졌다는 뜻입니다. 의도된 차단이며 끄지 마세요.
- 로고 원본을 `web-assets/logo-source/logo.png`(1024×1024 이상) 또는 `logo.svg`로 넣고 `/generate-web-assets` 실행
  → `npm run check:web-assets`가 통과하면 다시 배포.

### Google 검색 결과에 우리 아이콘 대신 지구본 아이콘이 뜬다
- `node scripts/check-web-assets.mjs --url https://<도메인>`으로 확인 → 통과하면 설정은 정상입니다.
- Google 반영에는 며칠~몇 주가 걸립니다. Search Console → URL 검사 → 홈페이지 **색인 생성 요청**으로 앞당길 수 있습니다.

---

## 5. 업데이트

### 새 버전 알림이 안 뜬다
- 알림은 하루 한 번만 확인합니다. 바로 확인하려면 `.cache/starter-version-check`를 지우고 새 세션을 시작하세요.
- 키트 저장소 접근 권한이 유지되고 있는지 확인: `gh repo view FineHourTeam/fine-harness-react-kit`
- `gh`가 없거나 로그인이 풀려 있으면 알림이 조용히 생략됩니다.

### `/update-starter` 중 "수동 병합"이 많이 나온다
- 프로젝트에서 직접 고친 파일(CLAUDE.md·knowledge 문서 등)은 덮어쓰지 않고 차이를 보여 줍니다. 가져올 줄만 고르면 됩니다.
- 판단이 어려우면 "이번엔 새 섹션만 가져와줘"처럼 범위를 좁혀 요청하세요. 누적 기록(`knowledge/mistakes/`, `docs/questions.md`)은
  어떤 경우에도 건드리지 않습니다.

---

## 6. 설치가 중간에 멈췄다

- bootstrap은 자동으로 되돌리지 않습니다. "지금까지 복사한 파일 목록 보여줘"라고 요청한 뒤
  (a) 문제를 해결하고 이어서 진행, (b) 복사한 파일 되돌리기, (c) 그대로 멈추기 중에서 고르세요.
- `CLAUDE.md.bak`이 있으면 설치 전 CLAUDE.md가 보관된 것입니다.
