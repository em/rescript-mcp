// src/server/McpServer.res
// Concern: bind the high-level @modelcontextprotocol/sdk/server/mcp McpServer class.
type t

@module("@modelcontextprotocol/sdk/server/mcp.js")
@new
external make: McpImplementation.t => t = "McpServer"

@module("@modelcontextprotocol/sdk/server/mcp.js")
@new
external makeWithOptions: (McpImplementation.t, McpServerOptions.t) => t = "McpServer"

@get
external server: t => McpLowLevelServer.t = "server"

@send
external connect: (t, McpTransport.t) => promise<unit> = "connect"

@send
external close: t => promise<unit> = "close"

@send
external isConnected: t => bool = "isConnected"

@send
external sendLoggingMessage: (t, dict<unknown>) => promise<unit> = "sendLoggingMessage"

@send
external sendLoggingMessageWithSessionId: (t, dict<unknown>, string) => promise<unit> =
  "sendLoggingMessage"

@send
external sendResourceListChanged: t => unit = "sendResourceListChanged"

@send
external sendToolListChanged: t => unit = "sendToolListChanged"

@send
external sendPromptListChanged: t => unit = "sendPromptListChanged"
