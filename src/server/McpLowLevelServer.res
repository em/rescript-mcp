// src/server/McpLowLevelServer.res
// Concern: bind the low-level @modelcontextprotocol/sdk/server Server class.
type t

@module("@modelcontextprotocol/sdk/server")
@new
external make: McpImplementation.t => t = "Server"

@module("@modelcontextprotocol/sdk/server")
@new
external makeWithOptions: (McpImplementation.t, McpServerOptions.t) => t = "Server"

@send
external connect: (t, McpTransport.t) => promise<unit> = "connect"

@send
external close: t => promise<unit> = "close"

@send
external ping: t => promise<unknown> = "ping"

@send
external registerCapabilities: (t, dict<unknown>) => unit = "registerCapabilities"

@return(nullable)
@send
external getClientCapabilities: t => option<dict<unknown>> = "getClientCapabilities"

@return(nullable)
@send
external getClientVersion: t => option<McpImplementation.t> = "getClientVersion"

@send
external sendLoggingMessage: (t, dict<unknown>) => promise<unit> = "sendLoggingMessage"

@send
external sendLoggingMessageWithSessionId: (t, dict<unknown>, string) => promise<unit> =
  "sendLoggingMessage"

@send
external sendResourceUpdated: (t, dict<unknown>) => promise<unit> = "sendResourceUpdated"

@send
external sendResourceListChanged: t => promise<unit> = "sendResourceListChanged"

@send
external sendToolListChanged: t => promise<unit> = "sendToolListChanged"

@send
external sendPromptListChanged: t => promise<unit> = "sendPromptListChanged"

@send
external setRequestHandlerRaw: (
  t,
  unknown,
  @uncurry (unknown, McpRequestHandlerExtra.t) => promise<unknown>,
) => unit = "setRequestHandler"
