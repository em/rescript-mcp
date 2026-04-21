import { describe, expect, it } from "vitest"
import { fileURLToPath } from "node:url"
import * as McpTest from "./helpers/McpTestBindings.mjs"

describe("binding surface", () => {
  it("constructs the package modules and exercises no-op lifecycle paths", async () => {
    const lowLevelServer = McpTest.makeLowLevelServer("surface-low-level", "1.0.0")
    const mcpServer = McpTest.makeMcpServerWithInstructions(
      "surface-mcp",
      "1.0.0",
      "surface instructions",
    )
    const client = McpTest.makeClientWithOptions("surface-client", "1.0.0")
    const webTransport = McpTest.makeWebStandardTransport()
    const nodeTransport = McpTest.makeNodeStreamableHttpTransport()
    const httpClientTransport = McpTest.makeStreamableHttpClientTransport(
      "http://127.0.0.1:65535/mcp",
    )
    const webSocketTransport = McpTest.makeWebSocketClientTransport("ws://127.0.0.1:65535/mcp")
    const stdioTransport = McpTest.makeStdioClientTransport(
      process.execPath,
      [fileURLToPath(new URL("./fixtures/StdioPingServer.mjs", import.meta.url))],
      process.cwd(),
    )

    expect(lowLevelServer).toBeTruthy()
    expect(mcpServer).toBeTruthy()
    expect(client).toBeTruthy()
    expect(httpClientTransport).toBeTruthy()
    expect(webSocketTransport).toBeTruthy()
    expect(stdioTransport).toBeTruthy()

    expect(McpTest.mcpServerIsConnected(mcpServer)).toBe(false)
    expect(McpTest.transportSessionId(webTransport)).toBeUndefined()
    expect(McpTest.httpClientProtocolVersion(httpClientTransport)).toBeUndefined()
    expect(McpTest.stdioClientPid(stdioTransport)).toBeUndefined()
    expect(McpTest.stdioClientStderr(stdioTransport)).toBeUndefined()
    expect(Array.isArray(McpTest.defaultInheritedEnvVars)).toBe(true)
    expect(McpTest.defaultEnvironment()).toEqual(expect.any(Object))

    await McpTest.transportStart(webTransport)
    await McpTest.transportClose(webTransport)
    await McpTest.transportStart(nodeTransport)
    await McpTest.transportClose(nodeTransport)

    const mcpServerTransport = McpTest.makeWebStandardTransport()
    await McpTest.connectMcpServer(mcpServer, mcpServerTransport)
    expect(McpTest.mcpServerIsConnected(mcpServer)).toBe(true)
    await McpTest.closeMcpServer(mcpServer)
  })
})
