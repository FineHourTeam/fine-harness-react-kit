#!/usr/bin/env bash
# PostToolUse(Edit|Write) 훅 — UI 규칙 결정론적 백스톱 (knowledge/rules.md § 디자인·UI)
# 검사 1: 빈 콜백 (onClick={() => {}} 등) — 동작 없는 버튼 금지
# 검사 2: window.alert/confirm/prompt 직접 호출 — components/ui 공용 Dialog만 허용
# 검사 3: 색상 하드코딩 (Tailwind arbitrary hex / inline style hex / 기본 팔레트 bg-red-600 등) — tokens.css 위계만 허용
# 검사 4: fontFamily 직접 지정 / 임의 폰트 클래스 — tokens.css --font-sans가 소유
# 검사 5: 폰트 크기 12px 미만 (text-[..px] / fontSize) — 최소 폰트 크기 12
# 검사 6: dangerouslySetInnerHTML — XSS 벡터, 에스컬레이션 대상
# 검사 7: features 간 직접 import — index.ts 공개 API/shared 경유만 허용
# 검사 8: 간격·라운드·섀도우 arbitrary value (p-[16px] 등) — Tailwind 스케일만 (4px 그리드)
# 검사 9: 한국어 카피 AI 티 (rules.md § 한국어 카피) — 문체 혼용(해요체 프로젝트만)·과잉 경어·"성공적으로"·
#         당신/여러분/혁신적인·변수 뒤 조사 하드코딩. src/**/*.ts(x) + src/locales/**/*.json, 주석 줄·테스트 제외
# 한계: 한 줄 패턴 휴리스틱(여러 줄 표현은 못 잡음) — 1차 방어는 CLAUDE.md/rules.md, 이 훅은 백스톱.
# exit 2 = stderr가 에이전트에게 피드백되어 즉시 수정하게 됨.

INPUT=$(cat)

# stdin JSON에서 file_path 추출 (jq 의존 없이) + 윈도우 역슬래시 정규화
FILE=$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed 's/.*:[[:space:]]*"//; s/"$//; s/\\\\/\//g; s/\\/\//g')

[ -z "$FILE" ] && exit 0

IS_LOCALE=0
case "$FILE" in
  */src/*.tsx|*/src/*.ts|*/src/*.jsx|*/src/*.js) ;;
  */src/locales/*.json) IS_LOCALE=1 ;;
  *) exit 0 ;;
esac

[ -f "$FILE" ] || exit 0

IN_STYLES=0; IN_UI=0
case "$FILE" in */src/styles/*) IN_STYLES=1 ;; esac
case "$FILE" in */src/components/ui/*) IN_UI=1 ;; esac
# 테스트 파일은 alert 모킹 등 예외가 많아 검사 2만 면제
IS_TEST=0
case "$FILE" in *.test.*|*.spec.*|*/__tests__/*) IS_TEST=1 ;; esac

ERRS=""
add_err() { ERRS="${ERRS}$1\n$2\n"; }

# ── 검사 1·2: 상호작용 규칙 (공용 래퍼 구현부인 components/ui는 제외) ──
if [ "$IN_UI" -eq 0 ]; then
  if HITS=$(grep -nE 'on[A-Z][a-zA-Z]*=\{[[:space:]]*(async[[:space:]]*)?\([^)]*\)[[:space:]]*=>[[:space:]]*\{[[:space:]]*\}[[:space:]]*\}' "$FILE"); then
    add_err "[UI 규칙 위반] 빈 콜백 발견 — 동작 없는 버튼·클릭 영역 금지 (기능 연결 / 요소 제거 / disabled 명시 중 택 1):" "$HITS"
  fi
  if [ "$IS_TEST" -eq 0 ]; then
    if HITS=$(grep -nE '(^|[^A-Za-z.])(window\.)?(alert|confirm|prompt)[[:space:]]*\(' "$FILE" | grep -vE '//.*'); then
      add_err "[UI 규칙 위반] alert/confirm/prompt 직접 호출 — src/components/ui/의 공용 Dialog/AlertDialog만 사용:" "$HITS"
    fi
  fi
fi

# ── 검사 3·4: 하드코딩 (토큰 정의부인 src/styles는 제외) ──
if [ "$IN_STYLES" -eq 0 ]; then
  if HITS=$(grep -nE '(text|bg|border|from|to|via|fill|stroke|ring|shadow|outline|decoration|accent|caret)-\[(#|rgb|hsl|oklch)' "$FILE"); then
    add_err "[디자인 토큰 위반] Tailwind arbitrary 색상 — tokens.css 위계(bg-primary 등)에 등록 후 사용 (rules.md § 디자인):" "$HITS"
  fi
  if HITS=$(grep -nE '(^|[^a-z-])(text|bg|border|from|to|via|fill|stroke|ring|outline|decoration|accent|caret|divide|placeholder)-(red|rose|pink|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|slate|gray|zinc|neutral|stone)-(50|[1-9]00|950)([^0-9]|$)' "$FILE"); then
    add_err "[디자인 토큰 위반] Tailwind 기본 팔레트 직접 사용(bg-red-600 등) — tokens.css 시맨틱 토큰(bg-primary·bg-destructive…)을 쓰고, 맞는 게 없으면 용도 토큰을 추가 (rules.md § 팔레트):" "$HITS"
  fi
  if HITS=$(grep -nE '(color|backgroundColor|borderColor|fill|stroke)[\"'"'"']?[[:space:]]*:[[:space:]]*[\"'"'"']?(#[0-9a-fA-F]{3,8}|rgb|hsl|oklch)' "$FILE"); then
    add_err "[디자인 토큰 위반] inline style 색상 하드코딩 — 색은 src/styles/tokens.css 위계에 등록 후 Tailwind 클래스로 사용:" "$HITS"
  fi
  if HITS=$(grep -nE '(fontFamily[[:space:]]*:|font-\[)' "$FILE"); then
    add_err "[디자인 토큰 위반] fontFamily 직접 지정 — 폰트는 tokens.css --font-sans가 소유:" "$HITS"
  fi
  # ── 검사 8: 간격·라운드·섀도우 arbitrary value — Tailwind 스케일만 (4px 배수 그리드가 일관성의 축) ──
  # 좌측 경계 가드: top-[..] 의 "p-["가 걸리지 않도록 앞 문자가 영숫자/하이픈이면 제외 (-m-[..]은 잡음)
  if HITS=$(grep -nE '(^|[^a-zA-Z0-9-])-?(p|px|py|ps|pe|pt|pb|pl|pr|m|mx|my|ms|me|mt|mb|ml|mr|gap|gap-x|gap-y|space-x|space-y|rounded(-[a-z]+)?|shadow)-\[' "$FILE"); then
    add_err "[디자인 토큰 위반] 간격/라운드/섀도우 arbitrary value — Tailwind 스케일(p-4 = 16px)만 사용 (rules.md § 디자인 패딩·라운드):" "$HITS"
  fi
fi

# ── 검사 5: 최소 폰트 12px (styles 포함 전체 — 토큰에서도 12 미만 금지) ──
if HITS=$(grep -nE 'text-\[(0?[0-9]|1[01])(\.[0-9]+)?px\]' "$FILE"); then
  add_err "[디자인 토큰 위반] 12px 미만 텍스트 — 최소 폰트 크기는 12(text-xs) (rules.md § 디자인):" "$HITS"
fi
if HITS=$(grep -nE 'fontSize[[:space:]]*:[[:space:]]*[\"'"'"']?(0?[0-9]|1[01])(px)?[\"'"'"']?[[:space:],}]' "$FILE"); then
  add_err "[디자인 토큰 위반] fontSize 12 미만 — 최소 폰트 크기는 12 (rules.md § 디자인):" "$HITS"
fi

# ── 검사 6: dangerouslySetInnerHTML ──
if HITS=$(grep -n 'dangerouslySetInnerHTML' "$FILE"); then
  add_err "[보안 규칙 위반] dangerouslySetInnerHTML — XSS 벡터. DOMPurify sanitize + 에스컬레이션 없이 사용 금지 (rules.md § UI 금지):" "$HITS"
fi

# ── 검사 7: features 간 직접 import ──
case "$FILE" in
  */src/features/*)
    THIS_FEATURE=$(printf '%s' "$FILE" | sed 's|.*/src/features/||' | cut -d/ -f1)
    SRC_ROOT="${FILE%%/src/features/*}/src"
    FILE_DIR=$(dirname "$FILE")
    # import 경로를 실제로 풀어서(상대 경로·@/ 별칭) 다른 feature의 "내부"를 가리키면 위반.
    # 다른 feature의 폴더 자체(= index.ts 공개 API)를 가리키는 import는 허용.
    BAD=""
    while IFS= read -r line; do
      spec=$(printf '%s' "${line#*:}" | sed -nE "s/.*from[[:space:]]*['\"]([^'\"]+)['\"].*/\1/p")
      case "$spec" in
        @/*) target="$SRC_ROOT/${spec#@/}" ;;
        src/*) target="${SRC_ROOT%/src}/$spec" ;;
        .*) target=$(realpath -m "$FILE_DIR/$spec" 2>/dev/null \
              || node -e 'console.log(require("path").resolve(process.argv[1], process.argv[2]))' "$FILE_DIR" "$spec" 2>/dev/null) ;;
        *) continue ;;
      esac
      case "$target" in
        "$SRC_ROOT"/features/*)
          rest="${target#"$SRC_ROOT"/features/}"; feat="${rest%%/*}"
          [ "$feat" = "$THIS_FEATURE" ] && continue
          [ "$rest" = "$feat" ] || [ "$rest" = "$feat/index" ] || BAD="$BAD$line"$'\n'
          ;;
      esac
    done < <(grep -nE "^[[:space:]]*(import|export) .*from[[:space:]]*['\"]" "$FILE")
    if [ -n "$BAD" ]; then
      add_err "[모듈 경계 위반] 다른 feature 내부 직접 import — 그 feature의 index.ts 공개 API(@/features/<이름>) 또는 shared 경유만 (rules.md § 모듈 경계):" "${BAD%$'\n'}"
    fi
    ;;
esac

# ── 검사 9: 한국어 카피 AI 티 (rules.md § 한국어 카피 — 언어판 블랙리스트) ──
# 주석 줄(//, *, /*)은 제외. 문체 검사는 CLAUDE.md "문체: 해요체" 프로젝트에서만 (합쇼체는 "좋아요" 같은 명사 오탐 때문에 체크리스트).
if [ "$IS_TEST" -eq 0 ]; then
  KO_SRC=$(grep -nvE '^[[:space:]]*(//|\*|/\*)' "$FILE")
  SPEECH=$(grep -oE '문체: *(해요체|합쇼체)' CLAUDE.md 2>/dev/null | head -1 | sed 's/문체: *//')
  if [ "$SPEECH" = "해요체" ]; then
    if HITS=$(printf '%s\n' "$KO_SRC" | grep -E '습니다|십시오|시기 바랍니다'); then
      add_err "[한국어 카피 위반] 해요체 프로젝트에 합쇼체 어미 — 화면마다 다른 어미가 대표적 AI 티. \"저장했어요\"처럼 (rules.md § 한국어 카피 — 문체):" "$HITS"
    fi
  fi
  if HITS=$(printf '%s\n' "$KO_SRC" | grep -E '하실 수|께서|시겠습니까'); then
    add_err "[한국어 카피 위반] 과잉 경어 — 높임은 문장 끝 한 번, 사물 존대 금지 (\"쓸 수 있어요\") (rules.md § 한국어 카피 — 경어):" "$HITS"
  fi
  if HITS=$(printf '%s\n' "$KO_SRC" | grep -E '성공적으로'); then
    add_err "[한국어 카피 위반] \"성공적으로\" — Successfully 직역. 완료 문구는 능동·결과형 (\"사진 3장을 올렸어요\") (rules.md § 한국어 카피 — 완료):" "$HITS"
  fi
  if HITS=$(printf '%s\n' "$KO_SRC" | grep -E '당신|여러분|혁신적인'); then
    add_err "[한국어 카피 위반] 호칭·과장 어휘 — 당신/여러분 대신 {name}님 또는 생략, 혁신적인 같은 최상급·과장 금지 (rules.md § 한국어 카피):" "$HITS"
  fi
  if HITS=$(printf '%s\n' "$KO_SRC" | grep -E '\}(이|가|을|를|은|는|로|으로)([[:space:]"'"'"'.,!?)}<]|$)'); then
    add_err "[한국어 카피 위반] 변수 뒤 조사 하드코딩({{name}}이·\${n}을) — 받침에 따라 틀림. 조사 없는 문장 또는 {{name}}님이 형태로 (rules.md § 한국어 카피 — 변수):" "$HITS"
  fi
fi

if [ -n "$ERRS" ]; then
  printf '%b' "$ERRS" >&2
  echo "파일: $FILE — 상세 규칙: knowledge/rules.md § 디자인·UI·한국어 카피" >&2
  exit 2
fi

exit 0
