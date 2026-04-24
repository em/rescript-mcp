// src/protocol/McpResourceContents.res
// Concern: construct and inspect resource contents returned by high-level resource handlers.
type t
type kind = [#text | #blob]

@obj
external text: (~uri: string, ~text: string, ~mimeType: string=?, ()) => t = ""

@obj
external blob: (~uri: string, ~blob: string, ~mimeType: string=?, ()) => t = ""

@get
external uri: t => string = "uri"

@return(nullable)
@get
external textValue: t => option<string> = "text"

@return(nullable)
@get
external blobValue: t => option<string> = "blob"

@return(nullable)
@get
external mimeType: t => option<string> = "mimeType"

let kind = contents =>
  switch (textValue(contents), blobValue(contents)) {
  | (Some(_), None) => #text
  | (None, Some(_)) => #blob
  | _ => JsError.throwWithMessage("Unsupported MCP resource contents shape")
  }
