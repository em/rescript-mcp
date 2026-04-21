type t

let make: McpImplementation.t => t
let makeWithOptions: (McpImplementation.t, McpServerOptions.t) => t
let connect: (t, McpTransport.t) => promise<unit>
let close: t => promise<unit>
let ping: t => promise<unknown>
let registerCapabilities: (t, dict<unknown>) => unit
let getClientCapabilities: t => option<dict<unknown>>
let getClientVersion: t => option<McpImplementation.t>
let sendLoggingMessage: (t, dict<unknown>) => promise<unit>
let sendLoggingMessageWithSessionId: (t, dict<unknown>, string) => promise<unit>
let sendResourceUpdated: (t, dict<unknown>) => promise<unit>
let sendResourceListChanged: t => promise<unit>
let sendToolListChanged: t => promise<unit>
let sendPromptListChanged: t => promise<unit>
let setRequestHandlerRaw: (
  t,
  unknown,
  @uncurry (unknown, McpRequestHandlerExtra.t) => promise<unknown>,
) => unit
