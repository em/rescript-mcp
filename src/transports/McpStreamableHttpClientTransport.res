// src/transports/McpStreamableHttpClientTransport.res
// Concern: bind the Streamable HTTP client transport.
type t = McpTransport.t

@module("@modelcontextprotocol/client")
@new
external make: Webapi.Url.t => t = "StreamableHTTPClientTransport"

@module("@modelcontextprotocol/client")
@new
external makeWithOptions: (Webapi.Url.t, McpStreamableHttpClientTransportOptions.t) => t =
  "StreamableHTTPClientTransport"

@send
external finishAuth: (t, string) => promise<unit> = "finishAuth"

@send
external terminateSession: t => promise<unit> = "terminateSession"

@send
external setProtocolVersionRaw: (t, string) => unit = "setProtocolVersion"

let setProtocolVersion = (transport, version) =>
  transport->setProtocolVersionRaw(version->McpProtocolVersion.toString)

@return(nullable)
@get
external protocolVersionRaw: t => option<string> = "protocolVersion"

let protocolVersion = transport =>
  transport->protocolVersionRaw->Option.map(McpProtocolVersion.fromString)
