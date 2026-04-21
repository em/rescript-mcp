// src/client/McpClient.res
// Concern: bind the high-level @modelcontextprotocol/sdk/client Client class.
type t

@module("@modelcontextprotocol/sdk/client")
@new
external make: McpImplementation.t => t = "Client"

@module("@modelcontextprotocol/sdk/client")
@new
external makeWithOptions: (McpImplementation.t, McpClientOptions.t) => t = "Client"

@send
external connect: (t, McpTransport.t) => promise<unit> = "connect"

@send
external connectWithOptions: (t, McpTransport.t, McpRequestOptions.t) => promise<unit> = "connect"

@send
external close: t => promise<unit> = "close"

@send
external ping: t => promise<unknown> = "ping"

@send
external pingWithOptions: (t, McpRequestOptions.t) => promise<unknown> = "ping"

@return(nullable)
@send
external getServerCapabilities: t => option<dict<unknown>> = "getServerCapabilities"

@return(nullable)
@send
external getServerVersion: t => option<McpImplementation.t> = "getServerVersion"

@return(nullable)
@send
external getInstructions: t => option<string> = "getInstructions"

@send
external complete: (t, dict<unknown>) => promise<unknown> = "complete"

@send
external completeWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown> =
  "complete"

@send external setLoggingLevel: (t, string) => promise<unknown> = "setLoggingLevel"

@send
external setLoggingLevelWithOptions: (t, string, McpRequestOptions.t) => promise<unknown> =
  "setLoggingLevel"

@send
external getPrompt: (t, dict<unknown>) => promise<unknown> = "getPrompt"

@send
external getPromptWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown> =
  "getPrompt"

@send
external listPrompts: t => promise<unknown> = "listPrompts"

@send
external listPromptsWithParamsAndOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
> = "listPrompts"

@send
external listResources: t => promise<unknown> = "listResources"

@send
external listResourcesWithParamsAndOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
> = "listResources"

@send
external listResourceTemplates: t => promise<unknown> = "listResourceTemplates"

@send
external listResourceTemplatesWithParamsAndOptions: (
  t,
  dict<unknown>,
  McpRequestOptions.t,
) => promise<unknown> = "listResourceTemplates"

@send
external readResource: (t, dict<unknown>) => promise<unknown> = "readResource"

@send
external readResourceWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown> =
  "readResource"

@send
external subscribeResource: (t, dict<unknown>) => promise<unknown> = "subscribeResource"

@send
external subscribeResourceWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
> = "subscribeResource"

@send
external unsubscribeResource: (t, dict<unknown>) => promise<unknown> = "unsubscribeResource"

@send
external unsubscribeResourceWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
> = "unsubscribeResource"

@send
external callToolRaw: (t, dict<unknown>) => promise<unknown> = "callTool"

@send
external callToolRawWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown> =
  "callTool"

@send
external callToolWithResultSchemaRaw: (t, dict<unknown>, unknown) => promise<unknown> = "callTool"

@send
external callToolWithResultSchemaRawAndOptions: (
  t,
  dict<unknown>,
  unknown,
  McpRequestOptions.t,
) => promise<unknown> = "callTool"

@send
external listTools: t => promise<unknown> = "listTools"

@send
external listToolsWithParamsAndOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
> = "listTools"
