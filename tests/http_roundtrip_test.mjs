import http from "node:http"
import { describe, expect, it } from "vitest"
import * as McpTest from "./helpers/McpTestBindings.mjs"

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject)
    server.listen(0, "127.0.0.1", () => {
      server.off("error", reject)
      resolve(server.address())
    })
  })
}

function closeServer(server) {
  return new Promise((resolve, reject) => {
    server.close(error => {
      if (error) {
        reject(error)
        return
      }

      resolve()
    })
  })
}

describe("streamable http roundtrip", () => {
  it("initializes and pings through the bound node and client transports", async () => {
    const server = McpTest.makeLowLevelServerWithInstructions(
      "http-test-server",
      "1.0.0",
      "http test server",
    )
    const transport = McpTest.makeNodeStreamableHttpStatefulJsonTransport("http-test-session")
    const client = McpTest.makeClient("http-test-client", "1.0.0")

    await McpTest.connectLowLevelServer(server, transport)

    const httpServer = http.createServer((req, res) => {
      void McpTest.nodeHandleRequest(transport, req, res).catch(error => {
        res.statusCode = 500
        res.end(String(error))
      })
    })

    const address = await listen(httpServer)
    const clientTransport = McpTest.makeStreamableHttpClientTransport(
      `http://127.0.0.1:${address.port}/mcp`,
    )

    try {
      await McpTest.connectClientWithTimeout(client, clientTransport, 5000)

      expect(McpTest.clientServerVersion(client)).toMatchObject({
        name: "http-test-server",
        version: "1.0.0",
      })
      expect(McpTest.clientInstructions(client)).toBe("http test server")
      expect(McpTest.clientServerCapabilities(client)).toEqual(expect.any(Object))
      expect(McpTest.httpClientProtocolVersion(clientTransport)).toEqual(expect.any(String))
      expect(McpTest.transportSessionId(transport)).toBe("http-test-session")

      const pingResult = await McpTest.pingClientWithTimeout(client, 5000)
      expect(pingResult).toEqual(expect.any(Object))
    } finally {
      await Promise.allSettled([
        McpTest.closeClient(client),
        McpTest.closeLowLevelServer(server),
        closeServer(httpServer),
      ])
    }
  })
})
