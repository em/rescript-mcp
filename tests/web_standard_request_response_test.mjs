import { describe, expect, it } from "vitest"
import * as McpTypes from "../src/core/McpTypes.mjs"
import * as McpTest from "./helpers/McpTestBindings.mjs"

describe("web-standard streamable http transport", () => {
  it("handles initialize and ping over Request and Response objects", async () => {
    const server = McpTest.makeLowLevelServerWithInstructions(
      "web-test-server",
      "1.0.0",
      "web test server",
    )
    const transport = McpTest.makeWebStandardStatefulJsonTransport("web-test-session")
    const authInfo = McpTest.makeAuthInfo("test-token", "test-client", ["read"])

    await McpTest.connectLowLevelServer(server, transport)

    const initializeRequest = new Request("http://example.test/mcp", {
      method: "POST",
      headers: {
        accept: "application/json, text/event-stream",
        "content-type": "application/json",
        "mcp-protocol-version": McpTypes.latestProtocolVersion,
      },
      body: JSON.stringify({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: McpTypes.latestProtocolVersion,
          capabilities: {},
          clientInfo: {
            name: "web-test-client",
            version: "1.0.0",
          },
        },
      }),
    })

    try {
      const initializeResponse = await McpTest.webHandleRequestWithAuthInfo(
        transport,
        initializeRequest,
        authInfo,
      )

      expect(initializeResponse.status).toBe(200)
      expect(initializeResponse.headers.get("content-type")).toContain("application/json")

      const initializeBody = await initializeResponse.json()
      expect(initializeBody.result.serverInfo).toMatchObject({
        name: "web-test-server",
        version: "1.0.0",
      })
      expect(initializeResponse.headers.get("mcp-session-id")).toBe("web-test-session")

      const pingResponse = await McpTest.webHandleRequest(
        transport,
        new Request("http://example.test/mcp", {
          method: "POST",
          headers: {
            accept: "application/json, text/event-stream",
            "content-type": "application/json",
            "mcp-protocol-version":
              initializeResponse.headers.get("mcp-protocol-version") ??
              McpTypes.latestProtocolVersion,
            "mcp-session-id": initializeResponse.headers.get("mcp-session-id") ?? "",
          },
          body: JSON.stringify({
            jsonrpc: "2.0",
            id: 2,
            method: "ping",
            params: {},
          }),
        }),
      )

      expect(pingResponse.status).toBe(200)
      expect(await pingResponse.json()).toMatchObject({
        jsonrpc: "2.0",
        id: 2,
        result: expect.any(Object),
      })
    } finally {
      await Promise.allSettled([
        McpTest.closeLowLevelServer(server),
        McpTest.transportClose(transport),
      ])
    }
  })
})
