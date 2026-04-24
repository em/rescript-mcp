// src/protocol/McpReadResourceResult.res
// Concern: construct `resources/read` results returned by high-level resource handlers.
type t

@obj
external makeRaw: (~contents: array<McpResourceContents.t>, ()) => t = ""

let make = contents => makeRaw(~contents=contents, ())

@get
external contents: t => array<McpResourceContents.t> = "contents"
