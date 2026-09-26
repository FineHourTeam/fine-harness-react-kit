# 디자인 시스템

이 프로젝트의 디자인 토큰 **단일 출처(source of truth)**.
UI를 만들기 전에 이 파일을 먼저 읽고 **토큰을 재사용**한다.
색상·타이포·간격·라운드·섀도우를 화면 코드에 하드코딩하지 말 것.

**값(value)은 여기서, 심볼(name)은 코드에서** — 원본이 바뀌면 토큰 값만 갱신하고
화면 코드는 손대지 않는다.

## 소스

- 원본 디자인시스템: `{{DESIGN_SYSTEM_SOURCE}}`  (git URL / Figma / "없음")
- 마지막 동기화: `{{TODAY}}`
- 로컬 캐시: `.cache/design-system/` (git clone, `.gitignore`에 포함)
- 반영 위치(생성물):
  - `src/styles/tokens.css` — CSS 변수 (`:root` 라이트 / `.dark` 다크) + Tailwind `@theme` 매핑
  - `src/components/ui/` — 토큰을 소비하는 공용 컴포넌트 (variant는 cva가 소유)
  - `index.html` — 폰트 프리로드·초기 테마 스크립트

## 토큰 매핑 (원본 → CSS 변수)

설치 시 H단계가 원본에서 추출해 채운다. 이후 수동 추가 금지 — 원본을 먼저 고친다.

| 원본 토큰 | 원본 값 | CSS 변수 | Tailwind 클래스 |
|---|---|---|---|
| color/primary | #______ | `--primary` | `bg-primary` / `text-primary` |
| color/background | #______ | `--background` | `bg-background` |
| color/foreground | #______ | `--foreground` | `text-foreground` |
| type/font | ______ | `--font-sans` | `font-sans` |
| radius/base | __ | `--radius` | `rounded-md` 등 |
| space 스케일 | 4px 단위 | (Tailwind 기본 스케일) | `p-4` = 16px |

## 강제 규칙 (에이전트 준수)

- 색상/폰트/간격/라운드/섀도우는 **위 토큰 심볼만** 사용. 리터럴 hex·`text-[#...]`·`p-[13px]` 같은
  arbitrary value 금지 (**훅이 차단**).
- **팔레트는 총 3~5색(hue 기준)** — 브랜드 1 + 뉴트럴 1~2 + 액센트 0~2. 상태색 3종은 예외.
  5색 초과·새 hue 추가는 사람 승인 필수 (rules.md § 팔레트 정량 상한).
- **다크모드 필수**: 모든 색은 `:root`와 `.dark` 양쪽을 정의. 단색 하드코딩 금지.
- 새 값이 필요하면 임의로 추가하지 말 것 → **원본 디자인시스템에 먼저 반영** 후 재동기화 (원본이
  "없음"이면 tokens.css 위계에 편입 제안 = 에스컬레이션).
- 공용 컴포넌트(`src/components/ui/`)를 우선 재사용. 없을 때만 신규 작성하되 토큰으로만 스타일링.
- 초기 테마 깜빡임(FOUC) 방지: `index.html` head의 인라인 스크립트가 localStorage/OS 선호를 읽어
  `.dark` 클래스를 **첫 페인트 전에** 부여한다 — 이 스크립트 제거 금지.

## 재동기화 (원본이 바뀌었을 때)

1. `git -C .cache/design-system pull` (또는 재클론 / Figma 재추출)
2. 바뀐 토큰을 `tokens.css`에 **값만** 반영 (변수명 유지 → 화면 코드 무수정).
3. `npm run build`로 회귀 확인 후, 이 파일의 "마지막 동기화" 날짜 갱신.
4. 라이트/다크 양쪽 렌더 확인 (토큰이 한쪽만 바뀌지 않았는지).
