# 아이콘 세트 (프로젝트 전용 SVG)

이 프로젝트는 **기본 아이콘 팩(lucide-react·react-icons·heroicons 등)을 쓰지 않는다.** 모든 아이콘은 이 폴더에서 제품 컨셉에
맞게 새로 그린다. 다른 서비스와 똑같은 아이콘이 "AI가 만든 기본 화면" 인상을 만들기 때문이다.

- 기본 아이콘 팩 import는 편집 즉시 훅이, shadcn CLI가 쓴 파일은 끝내기 직전 검사가 막는다.
- 화면 코드에 `<svg>`를 직접 쓰지 않는다 — 여기에 아이콘으로 등록하고 가져다 쓴다.
- 다른 아이콘 팩의 path를 복사하지 않는다 (라이선스·컨셉 불일치). 모양은 이 세트의 스타일 가이드로 새로 그린다.

## 스타일 가이드 (설치 때 컨셉으로 정한다 — 바꾸려면 사람 승인)

| 항목 | 값 | 컨셉과의 연결 (왜 이 값인가) |
|---|---|---|
| 제품 컨셉·톤 | (설치 때 채움) | CLAUDE.md 상단·§ 제품 톤앤매너 |
| 형태 언어 | (설치 때 채움 — 예: 기하학적 · 둥근 · 손그림 느낌 · 각진) | |
| 선 두께 | `icon-style.ts` strokeWidth | |
| 선 끝·꺾임 | `icon-style.ts` linecap · linejoin | |
| 채움 | 선 / 면 / 선+부분 면 | |
| 모서리 반경 | (예: 사각형 모서리 r=2) | |
| 참고 인상 | (예: "문구점 스티커처럼 두툼하고 둥글게") | |

## 그리드 규칙 (모든 아이콘 공통)

- 24×24 viewBox, 바깥 2px은 비워 둔다 (그리는 영역 20×20). 원형은 지름 20, 정사각형은 18 정도가 같은 크기로 보인다.
- 좌표는 정수 또는 .5 — 16px에서 흐려지지 않게. 선 두께가 홀수 px 계열이면 .5 좌표.
- 한 아이콘은 요소 1~4개. 16px(`size="sm"`)로 줄였을 때 알아볼 수 있어야 한다 — 디테일은 뺀다.
- 색은 `currentColor`만 (hex는 훅이 막는다). 두 톤이 필요하면 `opacity`로.
- 같은 뜻은 하나의 아이콘 — 만들기 전에 아래 목록에서 먼저 찾는다.

## 새 아이콘 만들기

1. 아래 목록에 같은 뜻의 아이콘이 있는지 확인한다.
2. `<뜻>-icon.tsx` 파일에 `createIcon`으로 만든다 — 이름은 모양이 아니라 뜻으로 (`DeleteIcon`, `TrashCanIcon` 아님):
   ```tsx
   import { createIcon } from "./icon";
   export const DeleteIcon = createIcon("DeleteIcon", <>
     <path d="M5 7h14" />
     <path d="M9 7V5h6v2" />
     <path d="M7 7l1 12h8l1-12" />
   </>);
   ```
3. `index.ts`에 export, 이 README 목록 표에 한 줄.
4. 16px·24px로 렌더해 스타일 가이드와 어긋나지 않는지 본다 (가능하면 스크린샷). 기존 아이콘 2~3개와 나란히 놓고 선 두께·크기
   감각이 같은지 확인한다.

## 쓰는 법

```tsx
import { DeleteIcon } from "@/components/icons";
<Button variant="ghost" size="icon" aria-label="메모 삭제"><DeleteIcon /></Button>   // 아이콘만 있는 버튼 → 버튼에 aria-label
<Button><DeleteIcon size="sm" /> 삭제</Button>                                     // 글자가 있으면 아이콘은 장식
<DeleteIcon label="삭제됨" />                                                       // 아이콘 혼자 뜻을 전할 때
```

## 목록

| 아이콘 | 뜻·쓰는 곳 | 만든 날 |
|---|---|---|
| (설치 때 만든 기본 세트부터 적는다) | | |
