// src/core/McpMessageExtraInfo.res
// Concern: construct and read the extra metadata attached to transport messages.
type t

@obj
external make: (
  ~requestInfo: McpRequestInfo.t=?,
  ~authInfo: McpAuthInfo.t=?,
  ~closeSSEStream: (unit => unit)=?,
  ~closeStandaloneSSEStream: (unit => unit)=?,
  (),
) => t = ""

@return(nullable)
@get
external requestInfo: t => option<McpRequestInfo.t> = "requestInfo"

@return(nullable)
@get
external authInfo: t => option<McpAuthInfo.t> = "authInfo"

@return(nullable)
@get
external closeSSEStream: t => option<unit => unit> = "closeSSEStream"

@return(nullable)
@get
external closeStandaloneSSEStream: t => option<unit => unit> = "closeStandaloneSSEStream"
