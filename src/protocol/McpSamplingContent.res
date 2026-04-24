// src/protocol/McpSamplingContent.res
// Concern: expose the exact text-image-audio union returned by no-tools sampling requests.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts` `SamplingContent`.
// Boundary: public protocol payload classified by the SDK's `type` discriminator.
// Why this shape: the no-tools sampling result is narrower than the broader content-block union, so the
// binding keeps this exact text-image-audio algebra instead of widening back to unrelated content variants.
// Coverage: tests/LowLevelCallbackRoundtrip_test.res
type t
type kind = [#text | #image | #audio]

@obj
external makeText: (@as("type") ~kind: string, ~text: string, ()) => t = ""

let text = text => makeText(~kind="text", ~text, ())

@obj
external makeBinary: (@as("type") ~kind: string, ~data: string, ~mimeType: string, ()) => t = ""

let image = (~data, ~mimeType) => makeBinary(~kind="image", ~data, ~mimeType, ())
let audio = (~data, ~mimeType) => makeBinary(~kind="audio", ~data, ~mimeType, ())

@get
external kindString: t => string = "type"

let kind = content =>
  switch kindString(content) {
  | "text" => #text
  | "image" => #image
  | "audio" => #audio
  | value => JsError.throwWithMessage("Unsupported MCP sampling content type: " ++ value)
  }

@return(nullable)
@get
external textValue: t => option<string> = "text"

@return(nullable)
@get
external data: t => option<string> = "data"

@return(nullable)
@get
external mimeType: t => option<string> = "mimeType"
