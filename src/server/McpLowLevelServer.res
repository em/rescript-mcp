// src/server/McpLowLevelServer.res
// Concern: bind the low-level @modelcontextprotocol/server Server class.
type t
type experimental

@module("@modelcontextprotocol/server")
@new
external make: McpImplementation.t => t = "Server"

@module("@modelcontextprotocol/server")
@new
external makeWithOptions: (McpImplementation.t, McpServerOptions.t) => t = "Server"

@get
external experimentalRaw: t => experimental = "experimental"

@get
external experimentalTasksRaw: experimental => McpLowLevelServerExperimentalTasks.t = "tasks"

let experimentalTasks = server => server->experimentalRaw->experimentalTasksRaw

@send
external connect: (t, McpTransport.t) => promise<unit> = "connect"

@send
external close: t => promise<unit> = "close"

@send
external ping: t => promise<McpEmptyResult.t> = "ping"

@send
external registerCapabilities: (t, dict<unknown>) => unit = "registerCapabilities"

@send
external getCapabilities: t => dict<unknown> = "getCapabilities"

@return(nullable)
@send
external getClientCapabilities: t => option<dict<unknown>> = "getClientCapabilities"

@return(nullable)
@send
external getClientVersion: t => option<McpImplementation.t> = "getClientVersion"

@send
external sendLoggingMessage: (t, McpLoggingMessageParams.t) => promise<unit> = "sendLoggingMessage"

@send
external sendLoggingMessageWithSessionId: (t, McpLoggingMessageParams.t, string) => promise<unit> =
  "sendLoggingMessage"

@send
external sendResourceUpdated: (t, McpResourceUpdatedParams.t) => promise<unit> = "sendResourceUpdated"

@send
external sendResourceListChanged: t => promise<unit> = "sendResourceListChanged"

@send
external sendToolListChanged: t => promise<unit> = "sendToolListChanged"

@send
external sendPromptListChanged: t => promise<unit> = "sendPromptListChanged"

@send
external createMessageRaw: (t, dict<unknown>) => promise<unknown> = "createMessage"

@send
external createMessageRawWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown> =
  "createMessage"

@send
external elicitInputRaw: (t, dict<unknown>) => promise<unknown> = "elicitInput"

@send
external elicitInputRawWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown> =
  "elicitInput"

@send
external listRoots: t => promise<McpListRootsResult.t> = "listRoots"

@send
external listRootsWithParamsAndOptions: (t, McpListRootsParams.t, McpRequestOptions.t) => promise<
  McpListRootsResult.t,
> = "listRoots"

@send
external setRequestHandlerWithMethodRaw: (
  t,
  string,
  @uncurry (unknown, McpRequestHandlerExtra.t) => promise<unknown>,
) => unit = "setRequestHandler"

let setRequestHandlerRaw = (server, method_, handler) =>
  server->setRequestHandlerWithMethodRaw(method_->McpMethod.requestToString, handler)
