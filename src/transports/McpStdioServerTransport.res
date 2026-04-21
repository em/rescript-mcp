// src/transports/McpStdioServerTransport.res
// Concern: bind the stdio server transport.
type t = McpTransport.t

@module("@modelcontextprotocol/sdk/server/stdio.js")
@new
external make: unit => t = "StdioServerTransport"

@module("@modelcontextprotocol/sdk/server/stdio.js")
@new
external makeWithStreams: (
  NodeJs.Stream.Readable.t<NodeJs.Buffer.t>,
  NodeJs.Stream.Writable.t<NodeJs.Buffer.t>,
) => t = "StdioServerTransport"
