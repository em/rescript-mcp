type t

let start: t => promise<unit>
let close: t => promise<unit>
let send: (t, unknown) => promise<unit>
let sendWithOptions: (t, unknown, McpTransportSendOptions.t) => promise<unit>
let sessionId: t => option<string>
