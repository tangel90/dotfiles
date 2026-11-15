// herdr-ctx: report an OpenCode session's context use and model to herdr as
// pane metadata ($ctx, $model), as statusline-command.sh does for Claude, so
// OpenCode agents show $ctx in herdr's sidebar and `herdr agent get` gives the
// lead the number. Stowed from dotfiles tools/opencode; herdr's own
// herdr-agent-state.js (status) is generated beside it.
//
// Context used = the last assistant step's input + cache read/write + output
// tokens; the window size comes from OpenCode's model catalogue, fetched once
// a day and cached as a small map in ~/.cache/herdr-ctx/limits.json.
// "07%" is zero-padded like Claude's, for the sidebar's colour rules.

import { execFile } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const PANE = process.env.HERDR_PANE_ID;
const CATALOGUE = "https://models.opencode.ai/experimental/v2.0/api.json";
const CACHE = path.join(process.env.XDG_CACHE_HOME || path.join(os.homedir(), ".cache"), "herdr-ctx", "limits.json");

let limits = null;
let loading = null;
let lastReport = "";
let model = { providerID: "", modelID: "" };

async function loadLimits() {
  try {
    const st = fs.statSync(CACHE);
    if (Date.now() - st.mtimeMs < 86400e3) return JSON.parse(fs.readFileSync(CACHE, "utf8"));
  } catch {}
  try {
    const res = await fetch(CATALOGUE, { signal: AbortSignal.timeout(30e3) });
    const all = await res.json();
    const map = {};
    for (const [prov, p] of Object.entries(all)) {
      for (const [id, m] of Object.entries(p?.models || {})) {
        if (m?.limit?.context) map[`${prov}/${id}`] = m.limit.context;
      }
    }
    fs.mkdirSync(path.dirname(CACHE), { recursive: true });
    fs.writeFileSync(CACHE, JSON.stringify(map));
    return map;
  } catch {
    try { return JSON.parse(fs.readFileSync(CACHE, "utf8")); } catch { return {}; }
  }
}

async function windowFor(providerID, modelID) {
  if (!limits) limits = await (loading ||= loadLimits());
  return limits[`${providerID}/${modelID}`];
}

function report(ctx, modelName) {
  const key = `${ctx}|${modelName}`;
  if (!PANE || key === lastReport) return;
  lastReport = key;
  execFile("herdr", ["pane", "report-metadata", PANE, "--source", "opencode-ctx",
    "--token", `ctx=${ctx}`, "--token", `model=${modelName}`], () => {});
}

async function update(tokens) {
  if (!tokens || !model.modelID) return;
  const used = (tokens.input || 0) + (tokens.output || 0) + (tokens.cache?.read || 0) + (tokens.cache?.write || 0);
  if (!used) return;
  const size = await windowFor(model.providerID, model.modelID);
  const ctx = size ? `${String(Math.min(100, Math.round((100 * used) / size))).padStart(2, "0")}%` : "";
  report(ctx, model.modelID);
}

const HerdrCtxPlugin = async () => ({
  event: async ({ event }) => {
    try {
      const props = event?.properties || event?.data || {};
      // V1 bus: assistant messages carry the model and the step's tokens.
      if (event?.type === "message.updated") {
        const info = props.info;
        if (info?.role !== "assistant") return;
        if (info.modelID) model = { providerID: info.providerID || "", modelID: info.modelID };
        await update(info.tokens);
      // V2 bus: a finished step carries its tokens; the model is the last one seen.
      } else if (event?.type === "session.step.ended") {
        await update(props.tokens);
      }
    } catch {}
  },
});

export default { id: "herdr.ctx", server: HerdrCtxPlugin, setup() {} };
