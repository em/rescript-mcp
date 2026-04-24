type t

let make: McpImplementation.t => t
let makeWithOptions: (McpImplementation.t, McpServerOptions.t) => t
let experimentalTasks: t => McpLowLevelServerExperimentalTasks.t
let connect: (t, McpTransport.t) => promise<unit>
let close: t => promise<unit>
let ping: t => promise<McpEmptyResult.t>
let registerCapabilities: (t, dict<unknown>) => unit
let getCapabilities: t => dict<unknown>
let getClientCapabilities: t => option<dict<unknown>>
let getClientVersion: t => option<McpImplementation.t>
let sendLoggingMessage: (t, McpLoggingMessageParams.t) => promise<unit>
let sendLoggingMessageWithSessionId: (t, McpLoggingMessageParams.t, string) => promise<unit>
let sendResourceUpdated: (t, McpResourceUpdatedParams.t) => promise<unit>
let sendResourceListChanged: t => promise<unit>
let sendToolListChanged: t => promise<unit>
let sendPromptListChanged: t => promise<unit>
let createMessageRaw: (t, dict<unknown>) => promise<unknown>
let createMessageRawWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let elicitInputRaw: (t, dict<unknown>) => promise<unknown>
let elicitInputRawWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let listRoots: t => promise<McpListRootsResult.t>
let listRootsWithParamsAndOptions: (t, McpListRootsParams.t, McpRequestOptions.t) => promise<
  McpListRootsResult.t,
>
let setRequestHandlerRaw: (
  t,
  McpMethod.request,
  @uncurry (unknown, McpRequestHandlerExtra.t) => promise<unknown>,
) => unit
