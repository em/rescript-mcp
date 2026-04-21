import { describe, expect, it } from "vitest"
import { fileURLToPath } from "node:url"
import * as McpTest from "./helpers/McpTestBindings.mjs"

describe("stdio roundtrip", () => {
  it("initializes and pings through the bound stdio client transport", async () => {
    const fixturePath = fileURLToPath(new URL("./fixtures/stdio-ping-server.mjs", import.meta.url))
    const client = McpTest.makeClientWithOptions("stdio-test-client", "1.0.0")
    const transport = McpTest.makeStdioClientTransport(
      process.execPath,
      [fixturePath],
      process.cwd(),
    )

    try {
      await McpTest.connectClientWithTimeout(client, transport, 5000)

      expect(McpTest.stdioClientPid(transport)).toEqual(expect.any(Number))
      expect(McpTest.clientServerVersion(client)).toMatchObject({
        name: "stdio-test-server",
        version: "1.0.0",
      })
      expect(McpTest.clientInstructions(client)).toBe("stdio test server")
      expect(McpTest.clientServerCapabilities(client)).toEqual(expect.any(Object))

      const pingResult = await McpTest.pingClientWithTimeout(client, 5000)
      expect(pingResult).toEqual(expect.any(Object))
    } finally {
      await Promise.allSettled([McpTest.closeClient(client), McpTest.transportClose(transport)])
    }
  })
})
