type t

let make: McpImplementation.t => t
let makeWithOptions: (McpImplementation.t, McpClientOptions.t) => t
let connect: (t, McpTransport.t) => promise<unit>
let connectWithOptions: (t, McpTransport.t, McpRequestOptions.t) => promise<unit>
let close: t => promise<unit>
let ping: t => promise<unknown>
let pingWithOptions: (t, McpRequestOptions.t) => promise<unknown>
let getServerCapabilities: t => option<dict<unknown>>
let getServerVersion: t => option<McpImplementation.t>
let getInstructions: t => option<string>
let complete: (t, dict<unknown>) => promise<unknown>
let completeWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let setLoggingLevel: (t, string) => promise<unknown>
let setLoggingLevelWithOptions: (t, string, McpRequestOptions.t) => promise<unknown>
let getPrompt: (t, dict<unknown>) => promise<unknown>
let getPromptWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let listPrompts: t => promise<unknown>
let listPromptsWithParamsAndOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let listResources: t => promise<unknown>
let listResourcesWithParamsAndOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
>
let listResourceTemplates: t => promise<unknown>
let listResourceTemplatesWithParamsAndOptions: (
  t,
  dict<unknown>,
  McpRequestOptions.t,
) => promise<unknown>
let readResource: (t, dict<unknown>) => promise<unknown>
let readResourceWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let subscribeResource: (t, dict<unknown>) => promise<unknown>
let subscribeResourceWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let unsubscribeResource: (t, dict<unknown>) => promise<unknown>
let unsubscribeResourceWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let callToolRaw: (t, dict<unknown>) => promise<unknown>
let callToolRawWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let callToolWithResultSchemaRaw: (t, dict<unknown>, unknown) => promise<unknown>
let callToolWithResultSchemaRawAndOptions: (
  t,
  dict<unknown>,
  unknown,
  McpRequestOptions.t,
) => promise<unknown>
let listTools: t => promise<unknown>
let listToolsWithParamsAndOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
