type t

let make: McpImplementation.t => t
let makeWithOptions: (McpImplementation.t, McpServerOptions.t) => t
let server: t => McpLowLevelServer.t
let connect: (t, McpTransport.t) => promise<unit>
let close: t => promise<unit>
let isConnected: t => bool
let sendLoggingMessage: (t, dict<unknown>) => promise<unit>
let sendLoggingMessageWithSessionId: (t, dict<unknown>, string) => promise<unit>
let sendResourceListChanged: t => unit
let sendToolListChanged: t => unit
let sendPromptListChanged: t => unit
