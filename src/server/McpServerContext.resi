type t

let sessionId: t => option<string>
let task: t => option<McpTaskContext.t>
let requestId: t => McpTypes.requestId
let requestMethod: t => McpMethod.request
let requestMeta: t => option<dict<unknown>>
let requestSignal: t => Webapi.Fetch.signal
let sendRelatedRequestRaw: (t, McpMethod.request, dict<unknown>) => promise<unknown>
let sendRelatedRequestRawWithOptions: (t, McpMethod.request, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
>
let sendRelatedNotificationRaw: (t, McpMethod.notification, dict<unknown>) => promise<unit>
let log: (t, McpLoggingMessageParams.level, unknown) => promise<unit>
let logWithLogger: (t, McpLoggingMessageParams.level, unknown, string) => promise<unit>
let elicitInputRaw: (t, dict<unknown>) => promise<unknown>
let elicitInputRawWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let requestSamplingRaw: (t, dict<unknown>) => promise<unknown>
let requestSamplingRawWithOptions: (t, dict<unknown>, McpRequestOptions.t) => promise<unknown>
let httpAuthInfo: t => option<McpAuthInfo.t>
let httpRequest: t => option<Webapi.Fetch.Request.t>
let closeSSE: t => option<unit => unit>
let closeStandaloneSSE: t => option<unit => unit>
