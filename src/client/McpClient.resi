type t

let make: McpImplementation.t => t
let makeWithOptions: (McpImplementation.t, McpClientOptions.t) => t
let experimentalTasks: t => McpClientExperimentalTasks.t
let registerCapabilities: (t, dict<unknown>) => unit
let setRequestHandlerRaw: (t, McpMethod.request, @uncurry (unknown, unknown) => promise<unknown>) => unit
let setNotificationHandlerRaw: (t, McpMethod.notification, @uncurry unknown => promise<unit>) => unit
let removeNotificationHandlerRaw: (t, McpMethod.notification) => unit
let connect: (t, McpTransport.t) => promise<unit>
let connectWithOptions: (t, McpTransport.t, McpRequestOptions.t) => promise<unit>
let close: t => promise<unit>
let ping: t => promise<McpEmptyResult.t>
let pingWithOptions: (t, McpRequestOptions.t) => promise<McpEmptyResult.t>
let getServerCapabilities: t => option<dict<unknown>>
let getServerVersion: t => option<McpImplementation.t>
let getNegotiatedProtocolVersion: t => option<McpProtocolVersion.t>
let getInstructions: t => option<string>
let complete: (t, McpCompleteParams.t) => promise<McpCompleteResult.t>
let completeWithOptions: (t, McpCompleteParams.t, McpRequestOptions.t) => promise<McpCompleteResult.t>
let setLoggingLevel: (t, McpLoggingMessageParams.level) => promise<McpEmptyResult.t>
let setLoggingLevelWithOptions: (t, McpLoggingMessageParams.level, McpRequestOptions.t) => promise<
  McpEmptyResult.t,
>
let getPrompt: (t, McpGetPromptParams.t) => promise<McpGetPromptResult.t>
let getPromptWithOptions: (t, McpGetPromptParams.t, McpRequestOptions.t) => promise<McpGetPromptResult.t>
let listPrompts: t => promise<McpListPromptsResult.t>
let listPromptsWithParamsAndOptions: (t, McpPaginatedParams.t, McpRequestOptions.t) => promise<
  McpListPromptsResult.t,
>
let listResources: t => promise<McpListResourcesResult.t>
let listResourcesWithParamsAndOptions: (t, McpPaginatedParams.t, McpRequestOptions.t) => promise<
  McpListResourcesResult.t,
>
let listResourceTemplates: t => promise<McpListResourceTemplatesResult.t>
let listResourceTemplatesWithParamsAndOptions: (
  t,
  McpPaginatedParams.t,
  McpRequestOptions.t,
) => promise<McpListResourceTemplatesResult.t>
let readResource: (t, McpResourceRequestParams.t) => promise<McpReadResourceResult.t>
let readResourceWithOptions: (t, McpResourceRequestParams.t, McpRequestOptions.t) => promise<
  McpReadResourceResult.t,
>
let subscribeResource: (t, McpResourceRequestParams.t) => promise<McpEmptyResult.t>
let subscribeResourceWithOptions: (t, McpResourceRequestParams.t, McpRequestOptions.t) => promise<
  McpEmptyResult.t,
>
let unsubscribeResource: (t, McpResourceRequestParams.t) => promise<McpEmptyResult.t>
let unsubscribeResourceWithOptions: (
  t,
  McpResourceRequestParams.t,
  McpRequestOptions.t,
) => promise<McpEmptyResult.t>
let callTool: (t, McpCallToolParams.t, McpStandardSchema.t<'output>) => promise<McpCallToolResult.t<'output>>
let callToolWithOptions: (
  t,
  McpCallToolParams.t,
  McpStandardSchema.t<'output>,
  McpRequestOptions.t,
) => promise<McpCallToolResult.t<'output>>
let callToolRaw: (t, McpCallToolParams.t) => promise<McpCallToolResult.raw>
let callToolRawWithOptions: (t, McpCallToolParams.t, McpRequestOptions.t) => promise<
  McpCallToolResult.raw,
>
let listTools: t => promise<McpListToolsResult.t>
let listToolsWithParamsAndOptions: (t, McpPaginatedParams.t, McpRequestOptions.t) => promise<
  McpListToolsResult.t,
>
