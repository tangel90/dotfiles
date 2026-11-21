// herdr-ctx: report pi's context use and model to herdr as pane metadata
// ($ctx, $model), as statusline-command.sh does for Claude and occtx for
// OpenCode, so pi agents show $ctx in herdr's sidebar. Stowed from dotfiles
// tools/pi; herdr's own extension beside it (herdr-agent-state.ts) reports
// working/idle and is managed by `herdr integration install pi`.
// @ts-nocheck

import { execFile } from "node:child_process";

const paneId = process.env.HERDR_PANE_ID;
let last = "";

function report(ctx) {
  const usage = ctx.getContextUsage?.();
  const model = ctx.model?.id ?? "";
  if (!usage || usage.percent == null) return;
  const pct = Math.min(100, Math.floor(usage.percent));
  const value = `${String(pct).padStart(2, "0")}%`;
  if (`${value}|${model}` === last) return;
  execFile(
    "herdr",
    ["pane", "report-metadata", paneId, "--source", "pi-ctx", "--token", `ctx=${value}`, "--token", `model=${model}`],
    { timeout: 2000 },
    (err) => {
      if (!err) last = `${value}|${model}`;
    },
  );
}

export default function (pi) {
  if (process.env.HERDR_ENV !== "1" || !paneId) return;
  pi.on("session_start", (_event, ctx) => report(ctx));
  pi.on("turn_end", (_event, ctx) => report(ctx));
  pi.on("model_select", (_event, ctx) => report(ctx));
}
