// src/transports/McpWebStandardStreamableHttpServerTransport.res
// Concern: bind the web-standard Streamable HTTP server transport.
type t = McpTransport.t

@module("@modelcontextprotocol/sdk/server/webStandardStreamableHttp")
@new
external make: unit => t = "WebStandardStreamableHTTPServerTransport"

@module("@modelcontextprotocol/sdk/server/webStandardStreamableHttp")
@new
external makeWithOptions: McpWebStandardStreamableHttpServerTransportOptions.t => t =
  "WebStandardStreamableHTTPServerTransport"

@send
external handleRequest: (t, Webapi.Fetch.request) => promise<Webapi.Fetch.response> = "handleRequest"

@send
external handleRequestWithOptions: (
  t,
  Webapi.Fetch.request,
  McpWebStandardStreamableHttpHandleRequestOptions.t,
) => promise<Webapi.Fetch.response> = "handleRequest"

@send
external closeSSEStream: (t, unknown) => unit = "closeSSEStream"

@send
external closeStandaloneSSEStream: t => unit = "closeStandaloneSSEStream"
