// src/transports/McpSSEClientTransport.res
// Concern: bind the deprecated but still public SSE client transport.
type t = McpTransport.t

@module("@modelcontextprotocol/client")
@new
external make: Webapi.Url.t => t = "SSEClientTransport"

@module("@modelcontextprotocol/client")
@new
external makeWithOptions: (Webapi.Url.t, McpSSEClientTransportOptions.t) => t =
  "SSEClientTransport"

@send
external finishAuth: (t, string) => promise<unit> = "finishAuth"

@send
external setProtocolVersionRaw: (t, string) => unit = "setProtocolVersion"

let setProtocolVersion = (transport, version) =>
  transport->setProtocolVersionRaw(version->McpProtocolVersion.toString)
