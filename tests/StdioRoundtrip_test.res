open Vitest

describe("stdio roundtrip", () => {
  testAsync("initializes and pings through the bound stdio client transport", async t => {
    let expect = value => t->expect(value)
    let client = McpTestBindings.makeClientWithOptions("stdio-test-client", "1.0.0")
    let transport = McpTestBindings.makeStdioClientTransport(
      TestSupport.execPath,
      [TestSupport.fixturePath("StdioPingServer.mjs")],
      TestSupport.cwd,
    )

    await McpTestBindings.connectClientWithTimeout(client, transport, 5000)

    (
      transport->McpTestBindings.stdioClientPid->Option.isSome,
      client->McpTestBindings.clientServerVersion,
      client->McpTestBindings.clientInstructions,
      client->McpTestBindings.clientServerCapabilities->Option.isSome,
    )
    ->expect
    ->Expect.toEqual((
      true,
      Some(McpTestBindings.makeImplementation("stdio-test-server", "1.0.0")),
      Some("stdio test server"),
      true,
    ))

    ignore(await McpTestBindings.pingClientWithTimeout(client, 5000))

    await TestSupport.settle([
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      transport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })
})
