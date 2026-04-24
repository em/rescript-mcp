// src/client/McpClient.res
// Concern: bind the installed `Client` class, its typed request/result methods, and its raw callback registration surface.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts`.
// Boundary: typed protocol methods return dedicated public modules, while raw request and notification callbacks keep payloads open at `unknown`.
// Why this shape: the SDK mixes high-level typed convenience methods with dynamic callback registration on one runtime object, so the binding keeps the typed path public and the dynamic seam explicit.
// Coverage: tests/ClientProtocolRoundtrip_test.res, tests/PublicWrapperCoverage_test.res, tests/PackageEntrypoints_test.res
type t
type experimental

@module("@modelcontextprotocol/client")
@new
external make: McpImplementation.t => t = "Client"

@module("@modelcontextprotocol/client")
@new
external makeWithOptions: (McpImplementation.t, McpClientOptions.t) => t = "Client"

@get
external experimentalRaw: t => experimental = "experimental"

@get
external experimentalTasksRaw: experimental => McpClientExperimentalTasks.t = "tasks"

let experimentalTasks = client => client->experimentalRaw->experimentalTasksRaw

@send
external registerCapabilities: (t, dict<unknown>) => unit = "registerCapabilities"

@send
external setRequestHandlerWithMethodRaw: (
  t,
  string,
  @uncurry (unknown, unknown) => promise<unknown>,
) => unit = "setRequestHandler"

let setRequestHandlerRaw = (client, method_, handler) =>
  client->setRequestHandlerWithMethodRaw(method_->McpMethod.requestToString, handler)

@send
external setNotificationHandlerWithMethodRaw: (t, string, @uncurry unknown => promise<unit>) => unit =
  "setNotificationHandler"

let setNotificationHandlerRaw = (client, method_, handler) =>
  client->setNotificationHandlerWithMethodRaw(method_->McpMethod.notificationToString, handler)

@send
external removeNotificationHandlerWithMethodRaw: (t, string) => unit = "removeNotificationHandler"

let removeNotificationHandlerRaw = (client, method_) =>
  client->removeNotificationHandlerWithMethodRaw(method_->McpMethod.notificationToString)

@send
external connect: (t, McpTransport.t) => promise<unit> = "connect"

@send
external connectWithOptions: (t, McpTransport.t, McpRequestOptions.t) => promise<unit> = "connect"

@send
external close: t => promise<unit> = "close"

@send
external ping: t => promise<McpEmptyResult.t> = "ping"

@send
external pingWithOptions: (t, McpRequestOptions.t) => promise<McpEmptyResult.t> = "ping"

@return(nullable)
@send
external getServerCapabilities: t => option<dict<unknown>> = "getServerCapabilities"

@return(nullable)
@send
external getServerVersion: t => option<McpImplementation.t> = "getServerVersion"

@return(nullable)
@send
external getNegotiatedProtocolVersionRaw: t => option<string> = "getNegotiatedProtocolVersion"

let getNegotiatedProtocolVersion = client =>
  client->getNegotiatedProtocolVersionRaw->Option.map(McpProtocolVersion.fromString)

@return(nullable)
@send
external getInstructions: t => option<string> = "getInstructions"

@send
external complete: (t, McpCompleteParams.t) => promise<McpCompleteResult.t> = "complete"

@send
external completeWithOptions: (t, McpCompleteParams.t, McpRequestOptions.t) => promise<
  McpCompleteResult.t,
> =
  "complete"

@send
external setLoggingLevel: (t, McpLoggingMessageParams.level) => promise<McpEmptyResult.t> =
  "setLoggingLevel"

@send
external setLoggingLevelWithOptions: (t, McpLoggingMessageParams.level, McpRequestOptions.t) => promise<
  McpEmptyResult.t,
> =
  "setLoggingLevel"

@send
external getPrompt: (t, McpGetPromptParams.t) => promise<McpGetPromptResult.t> = "getPrompt"

@send
external getPromptWithOptions: (t, McpGetPromptParams.t, McpRequestOptions.t) => promise<
  McpGetPromptResult.t,
> =
  "getPrompt"

@send
external listPrompts: t => promise<McpListPromptsResult.t> = "listPrompts"

@send
external listPromptsWithParamsAndOptions: (t, McpPaginatedParams.t, McpRequestOptions.t) => promise<
  McpListPromptsResult.t,
> = "listPrompts"

@send
external listResources: t => promise<McpListResourcesResult.t> = "listResources"

@send
external listResourcesWithParamsAndOptions: (t, McpPaginatedParams.t, McpRequestOptions.t) => promise<
  McpListResourcesResult.t,
> = "listResources"

@send
external listResourceTemplates: t => promise<McpListResourceTemplatesResult.t> = "listResourceTemplates"

@send
external listResourceTemplatesWithParamsAndOptions: (
  t,
  McpPaginatedParams.t,
  McpRequestOptions.t,
) => promise<McpListResourceTemplatesResult.t> = "listResourceTemplates"

@send
external readResource: (t, McpResourceRequestParams.t) => promise<McpReadResourceResult.t> =
  "readResource"

@send
external readResourceWithOptions: (t, McpResourceRequestParams.t, McpRequestOptions.t) => promise<
  McpReadResourceResult.t,
> =
  "readResource"

@send
external subscribeResource: (t, McpResourceRequestParams.t) => promise<McpEmptyResult.t> =
  "subscribeResource"

@send
external subscribeResourceWithOptions: (
  t,
  McpResourceRequestParams.t,
  McpRequestOptions.t,
) => promise<McpEmptyResult.t> = "subscribeResource"

@send
external unsubscribeResource: (t, McpResourceRequestParams.t) => promise<McpEmptyResult.t> =
  "unsubscribeResource"

@send
external unsubscribeResourceWithOptions: (
  t,
  McpResourceRequestParams.t,
  McpRequestOptions.t,
) => promise<McpEmptyResult.t> = "unsubscribeResource"

@send
external callToolWithResultSchemaRaw: (
  t,
  McpCallToolParams.t,
  McpStandardSchema.t<'output>,
) => promise<McpCallToolResult.raw> = "callTool"

@send
external callToolRaw: (t, McpCallToolParams.t) => promise<McpCallToolResult.raw> = "callTool"

let callTool = async (client, params, outputSchema) => {
  let result = await client->callToolWithResultSchemaRaw(params, outputSchema)
  result->McpCallToolResultInternal.fromRaw(outputSchema)
}

@send
external callToolRawWithOptions: (t, McpCallToolParams.t, McpRequestOptions.t) => promise<
  McpCallToolResult.raw,
> =
  "callTool"

@send
external callToolWithResultSchemaRawAndOptions: (
  t,
  McpCallToolParams.t,
  McpStandardSchema.t<'output>,
  McpRequestOptions.t,
) => promise<McpCallToolResult.raw> = "callTool"

let callToolWithOptions = async (client, params, outputSchema, options) => {
  let result = await client->callToolWithResultSchemaRawAndOptions(params, outputSchema, options)
  result->McpCallToolResultInternal.fromRaw(outputSchema)
}

@send
external listTools: t => promise<McpListToolsResult.t> = "listTools"

@send
external listToolsWithParamsAndOptions: (t, McpPaginatedParams.t, McpRequestOptions.t) => promise<
  McpListToolsResult.t,
> = "listTools"
