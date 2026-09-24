const { app, BrowserWindow } = require("electron");
const path = require("node:path");

function openCherryPit() {
  const provenanceSha = process.env.CHERRY_PIT_PROVENANCE_SHA || "unknown";
  const provenanceUtc = process.env.CHERRY_PIT_PROVENANCE_UTC || "unknown";
  const provenanceRoot = process.env.CHERRY_PIT_PROVENANCE_ROOT || "unknown";
  const window = new BrowserWindow({
    title: `CHERRY PIT — PROVENANCE 2026-09-24 — ${provenanceSha}`,
    width: 1600,
    height: 900,
    minWidth: 900,
    minHeight: 620,
    autoHideMenuBar: true,
    backgroundColor: "#06111f",
    webPreferences: { contextIsolation: true, nodeIntegration: false }
  });
  window.loadFile(path.join(__dirname, "index.html"), {
    query: {
      cherryPitProvenanceSha: provenanceSha,
      cherryPitProvenanceUtc: provenanceUtc,
      cherryPitProvenanceRoot: provenanceRoot
    }
  });
}

app.whenReady().then(() => {
  openCherryPit();
  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) openCherryPit();
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
