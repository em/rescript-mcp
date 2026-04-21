// tests/fixtures/StdioPingServer.res
// Concern: run a minimal stdio server process for end-to-end client transport tests.

let _server =
  McpLowLevelServer.makeWithOptions(
    McpImplementation.make(~name="stdio-test-server", ~version="1.0.0"),
    McpServerOptions.make(~instructions="stdio test server", ()),
  )

let _transport = McpStdioServerTransport.make()
let _connection = _server->McpLowLevelServer.connect(_transport)
