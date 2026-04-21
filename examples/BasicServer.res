// examples/BasicServer.res
// Concern: show the minimum low-level server and web transport wiring.
let implementation = McpImplementation.make(~name="example-server", ~version="0.1.0")
let server = McpLowLevelServer.make(implementation)
let transport =
  McpWebStandardStreamableHttpServerTransport.makeWithOptions(
    McpWebStandardStreamableHttpServerTransportOptions.make(~enableJsonResponse=true, ()),
  )

let _promise = server->McpLowLevelServer.connect(transport)
