// Doppio 0.5.0 uses BrowserFS's pre-1.4 construction API. BrowserFS 1.4 keeps
// that API working but emits one deprecation warning per mounted JAR. Hide only
// those known compatibility warnings; preserve all other warnings and errors.
const originalWarn = console.warn;
console.warn = (...args) => {
  const message = String(args[0]);
  if (
    message.includes("ZipFS.computeIndex is now deprecated") ||
    message.includes("Direct file system constructor usage is deprecated")
  ) {
    return;
  }
  originalWarn(...args);
};

require("doppiojvm/dist/release-cli/console/runner");
