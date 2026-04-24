open Vitest
open NodeJs

describe("streamable http roundtrip", () => {
  testAsync("initializes and pings through the bound node and client transports", async t => {
    let expect = value => t->expect(value)
    let server = McpTestBindings.makeLowLevelServerWithInstructions(
      "http-test-server",
      "1.0.0",
      "http test server",
    )
    let transport = McpTestBindings.makeNodeStreamableHttpStatefulJsonTransport("http-test-session")
    let client = McpTestBindings.makeClient("http-test-client", "1.0.0")

    await McpTestBindings.connectLowLevelServer(server, transport)

    let httpServer = Http.createServer((req, res) => {
      ignore(
        McpTestBindings.nodeHandleRequest(transport, req, res)->Promise.catch(_error => {
          res->Http.ServerResponse.setStatusCode(500)
          res->Http.ServerResponse.endWithData(Buffer.fromString("transport error"))
          Promise.resolve()
        }),
      )
    })
    let address = await TestSupport.listenHttpServer(httpServer)
    let clientTransport = McpTestBindings.makeStreamableHttpClientTransport(
      `http://127.0.0.1:${Int.toString(address.port)}/mcp`,
    )

    await McpTestBindings.connectClientWithTimeout(client, clientTransport, 5000)
    ignore(await McpTestBindings.pingClientWithTimeout(client, 5000))

    (
      client->McpTestBindings.clientServerVersion,
      client->McpTestBindings.clientNegotiatedProtocolVersion,
      client->McpTestBindings.clientInstructions,
      client->McpTestBindings.clientServerCapabilities != None,
      clientTransport->McpTestBindings.httpClientProtocolVersion,
      transport->McpTestBindings.transportSessionId,
    )
    ->expect
    ->Expect.toEqual((
      Some(McpTestBindings.makeImplementation("http-test-server", "1.0.0")),
      Some(McpTypes.latestProtocolVersion),
      Some("http test server"),
      true,
      Some(McpTypes.latestProtocolVersion),
      Some("http-test-session"),
    ))

    await TestSupport.settle([
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      server->McpTestBindings.closeLowLevelServer->TestSupport.closeIgnore,
      httpServer->TestSupport.closeHttpServer->TestSupport.closeIgnore,
    ])
  })
})
