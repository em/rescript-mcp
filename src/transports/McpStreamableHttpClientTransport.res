// src/transports/McpStreamableHttpClientTransport.res
// Concern: bind the Streamable HTTP client transport.
type t = McpTransport.t

@module("@modelcontextprotocol/sdk/client/streamableHttp.js")
@new
external make: Webapi.Url.t => t = "StreamableHTTPClientTransport"

@module("@modelcontextprotocol/sdk/client/streamableHttp.js")
@new
external makeWithOptions: (Webapi.Url.t, McpStreamableHttpClientTransportOptions.t) => t =
  "StreamableHTTPClientTransport"

@send
external finishAuth: (t, string) => promise<unit> = "finishAuth"

@send
external terminateSession: t => promise<unit> = "terminateSession"

@send
external setProtocolVersion: (t, string) => unit = "setProtocolVersion"

@return(nullable)
@get
external protocolVersion: t => option<string> = "protocolVersion"
