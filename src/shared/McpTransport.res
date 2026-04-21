// src/shared/McpTransport.res
// Concern: bind the SDK transport contract shared by all client and server transports.
type t

@send
external start: t => promise<unit> = "start"

@send
external close: t => promise<unit> = "close"

@send
external send: (t, unknown) => promise<unit> = "send"

@send
external sendWithOptions: (t, unknown, McpTransportSendOptions.t) => promise<unit> = "send"

@return(nullable)
@get
external sessionId: t => option<string> = "sessionId"
