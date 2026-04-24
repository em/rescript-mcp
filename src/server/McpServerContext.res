// src/server/McpServerContext.res
// Concern: expose the public high-level server handler context object.
type t
type mcpReq
type request
type notification
type http

@obj
external makeRequest: (~method: string, ~params: dict<unknown>=?, ()) => request = ""

@obj
external makeNotification: (~method: string, ~params: dict<unknown>=?, ()) => notification = ""

@get
external mcpReq: t => mcpReq = "mcpReq"

@return(nullable)
@get
external httpRaw: t => option<http> = "http"

@return(nullable)
@get
external taskRaw: t => option<McpTaskContext.t> = "task"

@return(nullable)
@get
external sessionId: t => option<string> = "sessionId"

@get
external requestId: mcpReq => McpTypes.requestId = "id"

@get
external requestMethodRaw: mcpReq => string = "method"

@return(nullable)
@get
external requestMeta: mcpReq => option<dict<unknown>> = "_meta"

@get
external requestSignal: mcpReq => Webapi.Fetch.signal = "signal"

@send
external sendRaw: (mcpReq, request) => promise<unknown> = "send"

@send
external sendRawWithOptions: (mcpReq, request, McpRequestOptions.t) => promise<unknown> = "send"

@send
external notifyRaw: (mcpReq, notification) => promise<unit> = "notify"

@send
external log: (mcpReq, McpLoggingMessageParams.level, unknown) => promise<unit> = "log"

@send
external logWithLogger: (mcpReq, McpLoggingMessageParams.level, unknown, string) => promise<unit> =
  "log"

@send
external elicitInputRaw: (mcpReq, dict<unknown>) => promise<unknown> = "elicitInput"

@send
external elicitInputRawWithOptions: (mcpReq, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
> = "elicitInput"

@send
external requestSamplingRaw: (mcpReq, dict<unknown>) => promise<unknown> = "requestSampling"

@send
external requestSamplingRawWithOptions: (mcpReq, dict<unknown>, McpRequestOptions.t) => promise<
  unknown,
> = "requestSampling"

@return(nullable)
@get
external authInfoRaw: http => option<McpAuthInfo.t> = "authInfo"

@return(nullable)
@get
external requestRaw: http => option<Webapi.Fetch.Request.t> = "req"

@return(nullable)
@get
external closeSSERaw: http => option<unit => unit> = "closeSSE"

@return(nullable)
@get
external closeStandaloneSSERaw: http => option<unit => unit> = "closeStandaloneSSE"

let requestId = context => context->mcpReq->requestId
let requestMethod = context => context->mcpReq->requestMethodRaw->McpMethod.requestFromString
let requestMeta = context => context->mcpReq->requestMeta
let requestSignal = context => context->mcpReq->requestSignal
let sendRelatedRequestRaw = (context, method_, params) =>
  context->mcpReq->sendRaw(makeRequest(~method=method_->McpMethod.requestToString, ~params, ()))
let sendRelatedRequestRawWithOptions = (context, method_, params, options) =>
  context
  ->mcpReq
  ->sendRawWithOptions(makeRequest(~method=method_->McpMethod.requestToString, ~params, ()), options)
let sendRelatedNotificationRaw = (context, method_, params) =>
  context
  ->mcpReq
  ->notifyRaw(makeNotification(~method=method_->McpMethod.notificationToString, ~params, ()))
let log = (context, level, data) => context->mcpReq->log(level, data)
let logWithLogger = (context, level, data, logger) => context->mcpReq->logWithLogger(level, data, logger)
let elicitInputRaw = (context, params) => context->mcpReq->elicitInputRaw(params)
let elicitInputRawWithOptions = (context, params, options) =>
  context->mcpReq->elicitInputRawWithOptions(params, options)
let requestSamplingRaw = (context, params) => context->mcpReq->requestSamplingRaw(params)
let requestSamplingRawWithOptions = (context, params, options) =>
  context->mcpReq->requestSamplingRawWithOptions(params, options)
let httpAuthInfo = context => context->httpRaw->Option.flatMap(authInfoRaw)
let httpRequest = context => context->httpRaw->Option.flatMap(requestRaw)
let closeSSE = context => context->httpRaw->Option.flatMap(closeSSERaw)
let closeStandaloneSSE = context => context->httpRaw->Option.flatMap(closeStandaloneSSERaw)
let task = context => context->taskRaw
