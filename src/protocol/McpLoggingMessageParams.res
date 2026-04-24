// src/protocol/McpLoggingMessageParams.res
// Concern: bind notifications/message params as a typed protocol object with open data payload.
type t
type level = [#alert | #critical | #debug | #emergency | #error | #info | #notice | #warning]

@obj
external make: (~level: level, ~data: unknown, ~logger: string=?, ~_meta: dict<unknown>=?, ()) => t =
  ""

@get
external level: t => level = "level"

@get
external data: t => unknown = "data"

@return(nullable)
@get
external logger: t => option<string> = "logger"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
