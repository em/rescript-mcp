import { describe, it } from "vitest"
import { execFileSync } from "node:child_process"
import { fileURLToPath } from "node:url"

function importWithNode(path) {
  execFileSync(
    process.execPath,
    [
      "--input-type=module",
      "-e",
      `await import(${JSON.stringify(path)});`,
    ],
    { stdio: "pipe" },
  )
}

describe("published entrypoints", () => {
  it("load under plain node esm resolution", () => {
    importWithNode(fileURLToPath(new URL("../src/Mcp.mjs", import.meta.url)))
    importWithNode(fileURLToPath(new URL("../src/core/McpCore.mjs", import.meta.url)))
    importWithNode(fileURLToPath(new URL("../src/shared/McpShared.mjs", import.meta.url)))
    importWithNode(fileURLToPath(new URL("../src/server/McpServerBindings.mjs", import.meta.url)))
    importWithNode(fileURLToPath(new URL("../src/client/McpClientBindings.mjs", import.meta.url)))
    importWithNode(fileURLToPath(new URL("../src/transports/McpTransports.mjs", import.meta.url)))
  })
})
