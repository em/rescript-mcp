type t

let authInfo: t => option<McpAuthInfo.t>
let sessionId: t => option<string>
let requestId: t => McpTypes.requestId
let taskId: t => option<string>
let requestInfo: t => option<McpRequestInfo.t>
let closeSSEStream: t => option<unit => unit>
let closeStandaloneSSEStream: t => option<unit => unit>
