// src/transports/McpNodeStreamableHttpServerTransport.res
// Concern: bind the Node Streamable HTTP server transport.
type t = McpTransport.t

@module("@modelcontextprotocol/node")
@new
external make: unit => t = "NodeStreamableHTTPServerTransport"

@module("@modelcontextprotocol/node")
@new
external makeWithOptions: McpNodeStreamableHttpServerTransportOptions.t => t =
  "NodeStreamableHTTPServerTransport"

@send
external handleRequest: (t, NodeJs.Http.IncomingMessage.t, NodeJs.Http.ServerResponse.t) => promise<
  unit,
> =
  "handleRequest"

@send
external handleRequestWithParsedBody: (
  t,
  NodeJs.Http.IncomingMessage.t,
  NodeJs.Http.ServerResponse.t,
  unknown,
) => promise<unit> = "handleRequest"

@send
external closeSSEStream: (t, unknown) => unit = "closeSSEStream"

@send
external closeStandaloneSSEStream: t => unit = "closeStandaloneSSEStream"
