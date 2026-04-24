open Vitest

describe("binding surface", () => {
  testAsync("constructs the package modules and exercises no-op lifecycle paths", async t => {
    let expect = value => t->expect(value)
    let _lowLevelServer = McpTestBindings.makeLowLevelServer("surface-low-level", "1.0.0")
    let mcpServer = McpTestBindings.makeMcpServerWithInstructions(
      "surface-mcp",
      "1.0.0",
      "surface instructions",
    )
    let client = McpTestBindings.makeClientWithOptions("surface-client", "1.0.0")
    let webTransport = McpTestBindings.makeWebStandardTransport()
    let nodeTransport = McpTestBindings.makeNodeStreamableHttpTransport()
    let httpClientTransport = McpTestBindings.makeStreamableHttpClientTransport(
      "http://127.0.0.1:65535/mcp",
    )
    let stdioTransport = McpTestBindings.makeStdioClientTransport(
      TestSupport.execPath,
      [TestSupport.fixturePath("StdioPingServer.mjs")],
      TestSupport.cwd,
    )

    (
      mcpServer->McpTestBindings.mcpServerIsConnected,
      client->McpTestBindings.clientServerVersion,
      client->McpTestBindings.clientInstructions,
      webTransport->McpTestBindings.transportSessionId,
      httpClientTransport->McpTestBindings.httpClientProtocolVersion,
      stdioTransport->McpTestBindings.stdioClientPid,
      stdioTransport->McpTestBindings.stdioClientStderr,
    )
    ->expect
    ->Expect.toEqual((false, None, None, None, None, None, None))

    await webTransport->McpTestBindings.transportStart
    await webTransport->McpTestBindings.transportClose
    await nodeTransport->McpTestBindings.transportStart
    await nodeTransport->McpTestBindings.transportClose

    let mcpServerTransport = McpTestBindings.makeWebStandardTransport()
    await McpTestBindings.connectMcpServer(mcpServer, mcpServerTransport)
    mcpServer->McpTestBindings.mcpServerIsConnected->expect->Expect.toBe(true)

    await TestSupport.settle([
      mcpServer->McpTestBindings.closeMcpServer->TestSupport.closeIgnore,
      mcpServerTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      stdioTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })
})
