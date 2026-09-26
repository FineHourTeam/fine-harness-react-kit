// Sentry 초기화 — main.tsx 최상단에서 import "./lib/sentry" 한 줄로 활성화.
// DSN 미설정(로컬 등)이면 자동 비활성. 소스맵 업로드는 @sentry/vite-plugin이 빌드에서 담당
// (unknown-unknowns #50 — 소스맵 없으면 Ops Loop 분석 품질 급락).
import * as Sentry from "@sentry/react";
import { env } from "./env";

if (env.VITE_SENTRY_DSN && import.meta.env.PROD) {
  Sentry.init({
    dsn: env.VITE_SENTRY_DSN,
    integrations: [
      Sentry.browserTracingIntegration(),
      Sentry.replayIntegration(),
    ],
    // 성능 트레이스는 10%면 추세 파악에 충분 — 비용 통제
    tracesSampleRate: 0.1,
    // 세션 리플레이: 평상시 10%, 에러 발생 세션은 100%
    replaysSessionSampleRate: 0.1,
    replaysOnErrorSampleRate: 1.0,
    // 배포 추적 — CI에서 주입 (없으면 생략됨)
    release: import.meta.env.VITE_APP_VERSION as string | undefined,
    // 브라우저 확장·서드파티 스크립트 소음 차단
    ignoreErrors: [
      "top.GLOBALS",
      /extension\//i,
      /^chrome:\/\//i,
      /^moz-extension:\/\//i,
    ],
  });
}

// 배포 직후 옛 청크 요청 실패는 정상 시나리오 — 자동 새로고침으로 복구
// (unknown-unknowns #52). 에러 바운더리 대신 전역에서 1회 처리.
window.addEventListener("vite:preloadError", () => {
  window.location.reload();
});
