const { app, BrowserWindow } = require("electron");
const path = require("node:path");

function openCherryPit() {
  const window = new BrowserWindow({
    title: "Cherry Pit",
    width: 1600,
    height: 900,
    minWidth: 900,
    minHeight: 620,
    autoHideMenuBar: true,
    backgroundColor: "#06111f",
    webPreferences: { contextIsolation: true, nodeIntegration: false }
  });
  window.loadFile(path.join(__dirname, "index.html"));
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
