// herdr-ctx: report an OpenCode session's context use and model to herdr as
// pane metadata ($ctx, $model), as statusline-command.sh does for Claude, so
// OpenCode agents show $ctx in herdr's sidebar and `herdr agent get` gives the
// lead the number. Stowed from dotfiles tools/opencode and registered in
// tui.jsonc next to herdr's own TUI plugin.
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

// A TUI plugin (tui.jsonc), not a server plugin: in OpenCode's full
// interface only the TUI runs in the pane (HERDR_PANE_ID) and sees its
// session's events; a server plugin's events don't fire there.
async function tui(api) {
  fs.mkdirSync(path.dirname(CACHE), { recursive: true });
  const log = (m) => { try { fs.appendFileSync(path.join(path.dirname(CACHE), "events.log"), m + "\n"); } catch {} };
  log(`tui start pane=${PANE} keys=${Object.keys(api || {}).join(",")}`);
  for (const t of ["message.updated", "message.part.updated", "session.updated", "session.status", "session.idle"]) {
    api.event.on(t, (e) => log(`${t} ${JSON.stringify(e?.properties).slice(0, 300)}`));
  }
  if (!PANE) return;
  const unsubscribe = api.event.on("message.updated", async (event) => {
    try {
      const info = event?.properties?.info;
      if (process.env.HERDR_CTX_DEBUG) {
        fs.mkdirSync(path.dirname(CACHE), { recursive: true });
        fs.appendFileSync(path.join(path.dirname(CACHE), "events.log"), `${JSON.stringify(info).slice(0, 400)}\n`);
      }
      if (info?.role !== "assistant") return;
      if (info.modelID) model = { providerID: info.providerID || "", modelID: info.modelID };
      await update(info.tokens);
    } catch {}
  });
  return () => unsubscribe?.();
}

export default { id: "herdr.ctx", setup() {}, tui };
