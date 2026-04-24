open Vitest
open NodeJs

describe("published entrypoints", () => {
  test("load under plain node esm resolution", _ => {
    TestSupport.importWithNode(Path.join([TestSupport.cwd, "src", "Mcp.mjs"]))
    TestSupport.importWithNode(Path.join([TestSupport.cwd, "src", "auth", "McpAuth.mjs"]))
    TestSupport.importWithNode(Path.join([TestSupport.cwd, "src", "protocol", "McpProtocol.mjs"]))
    TestSupport.importWithNode(Path.join([TestSupport.cwd, "src", "core", "McpCore.mjs"]))
    TestSupport.importWithNode(Path.join([TestSupport.cwd, "src", "shared", "McpShared.mjs"]))
    TestSupport.importWithNode(Path.join([TestSupport.cwd, "src", "server", "McpServerBindings.mjs"]))
    TestSupport.importWithNode(Path.join([TestSupport.cwd, "src", "client", "McpClientBindings.mjs"]))
    TestSupport.importWithNode(Path.join([TestSupport.cwd, "src", "transports", "McpTransports.mjs"]))
  })
})
