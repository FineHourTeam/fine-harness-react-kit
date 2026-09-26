// REACT_FIREBASE_SETUP.md / setup-sentry-autofix 스킬 참조
// functions/index.js (또는 functions/sentryToGithub.js)에 복사해서 사용.
// Sentry 신규 이슈 웹훅(Internal Integration) → 서명 검증 → GitHub Actions "Sentry AutoFix"
// 워크플로우를 workflow_dispatch로 원격 트리거한다 (Ops Loop: 자동 감지 → dispatch).
//
// [GITHUB_OWNER] / [GITHUB_REPO] / [BASE_BRANCH] 는 프로젝트 값으로 치환할 것
// 시크릿 2종은 Firebase Secret Manager에 등록 (setup-sentry-autofix 스킬이 안내):
//   firebase functions:secrets:set GITHUB_PAT
//     → fine-grained PAT, 이 레포 단일 대상, "Actions: Read and write" 권한만 부여
//   firebase functions:secrets:set SENTRY_CLIENT_SECRET
//     → Sentry Internal Integration의 Client Secret (웹훅 서명 검증용)

const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const crypto = require("crypto");

const GITHUB_PAT = defineSecret("GITHUB_PAT");
const SENTRY_CLIENT_SECRET = defineSecret("SENTRY_CLIENT_SECRET");

const GITHUB_OWNER = "[GITHUB_OWNER]";
const GITHUB_REPO = "[GITHUB_REPO]";
const WORKFLOW_FILE = "sentry-autofix.yml";
const TARGET_REF = "[BASE_BRANCH]"; // 워크플로우 파일이 존재하는 브랜치 (보통 main)

/**
 * Sentry 웹훅 서명 검증 — body 원문의 HMAC-SHA256(Client Secret)이
 * sentry-hook-signature 헤더와 일치해야 한다. 불일치 요청은 무시(위조 방지).
 */
function isValidSignature(req) {
  const signature = req.get("sentry-hook-signature");
  if (!signature) return false;
  const hmac = crypto.createHmac("sha256", SENTRY_CLIENT_SECRET.value());
  hmac.update(req.rawBody, "utf8");
  const digest = hmac.digest("hex");
  try {
    return crypto.timingSafeEqual(Buffer.from(digest), Buffer.from(signature));
  } catch {
    return false;
  }
}

/**
 * GitHub Actions workflow_dispatch REST API 호출.
 * 실패해도 200을 반환 — Sentry 웹훅 재시도 폭주 방지.
 */
async function dispatchAutofixWorkflow(issue) {
  const payload = {
    ref: TARGET_REF,
    inputs: {
      issue_id: String(issue.id ?? "unknown"),
      issue_title: String(issue.title ?? "").slice(0, 200),
      issue_culprit: String(issue.culprit ?? "").slice(0, 200),
      issue_url: String(issue.permalink ?? ""),
    },
  };

  const url =
    `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}` +
    `/actions/workflows/${WORKFLOW_FILE}/dispatches`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${GITHUB_PAT.value()}`,
      "Accept": "application/vnd.github+json",
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    const body = await res.text();
    logger.error("GitHub workflow_dispatch 실패", {status: res.status, body, issueId: issue.id});
    return;
  }

  logger.info("Sentry AutoFix 워크플로우 트리거됨", {issueId: issue.id});
}

exports.sentryToGithub = onRequest(
  {secrets: [GITHUB_PAT, SENTRY_CLIENT_SECRET]},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }
    if (!isValidSignature(req)) {
      logger.warn("Sentry 웹훅 서명 불일치 — 무시됨");
      res.status(401).send("Invalid signature");
      return;
    }

    // Sentry Internal Integration 페이로드:
    // - Alert Rule Action 경유: sentry-hook-resource: event_alert, data.event + data.issue_url
    // - Issue 웹훅: sentry-hook-resource: issue, action: created, data.issue
    const resource = req.get("sentry-hook-resource");
    const body = req.body ?? {};

    let issue = null;
    if (resource === "issue" && body.action === "created" && body.data?.issue) {
      const i = body.data.issue;
      issue = {id: i.id, title: i.title, culprit: i.culprit, permalink: i.permalink};
    } else if (resource === "event_alert" && body.data?.event) {
      const e = body.data.event;
      issue = {
        id: e.issue_id ?? e.event_id,
        title: e.title ?? e.message,
        culprit: e.culprit,
        permalink: e.web_url ?? body.data.issue_url,
      };
    }

    if (!issue) {
      // installation 검증 핑 등 — 정상 응답만 하고 종료
      logger.info("처리 대상 아님", {resource, action: body.action});
      res.status(200).send("ignored");
      return;
    }

    await dispatchAutofixWorkflow(issue);
    res.status(200).send("ok");
  },
);
