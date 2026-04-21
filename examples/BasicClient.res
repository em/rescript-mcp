// examples/BasicClient.res
// Concern: show the minimum client and Streamable HTTP transport wiring.
let implementation = McpImplementation.make(~name="example-client", ~version="0.1.0")
let client = McpClient.make(implementation)
let transport =
  McpStreamableHttpClientTransport.make(Webapi.Url.make("http://127.0.0.1:8788/mcp"))

let _promise = client->McpClient.connect(transport)
