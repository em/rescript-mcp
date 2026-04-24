// src/protocol/McpContentBlock.res
// Concern: construct and inspect protocol content blocks used by prompt and tool result surfaces.
// Source: @modelcontextprotocol/client and @modelcontextprotocol/server ContentBlock schema unions.
// Boundary: public protocol payload classified by the SDK's `type` discriminator.
// Why this shape: the SDK exposes a real tagged union. The binding keeps the runtime object opaque and
// exposes explicit constructors and accessors so callers can handle all bound variants without casting.
type t
type kind = [#text | #image | #audio | #resourceLink | #resource]

@obj
external makeText: (@as("type") ~kind: string, ~text: string, ()) => t = ""

let text = text => makeText(~kind="text", ~text, ())

@obj
external makeBinary: (@as("type") ~kind: string, ~data: string, ~mimeType: string, ()) => t = ""

let image = (~data, ~mimeType) => makeBinary(~kind="image", ~data, ~mimeType, ())
let audio = (~data, ~mimeType) => makeBinary(~kind="audio", ~data, ~mimeType, ())

@obj
external makeResourceLink: (
  @as("type") ~kind: string,
  ~uri: string,
  ~name: string,
  ~description: string=?,
  ~mimeType: string=?,
  ~size: float=?,
  (),
) => t = ""

let resourceLink = (~uri, ~name, ~description=?, ~mimeType=?, ~size=?) =>
  makeResourceLink(~kind="resource_link", ~uri, ~name, ~description?, ~mimeType?, ~size?, ())

@obj
external makeResource: (@as("type") ~kind: string, ~resource: McpResourceContents.t, ()) => t = ""

let resource = resource => makeResource(~kind="resource", ~resource, ())

@get
external kindString: t => string = "type"

let kind = block =>
  switch kindString(block) {
  | "text" => #text
  | "image" => #image
  | "audio" => #audio
  | "resource_link" => #resourceLink
  | "resource" => #resource
  | value => JsError.throwWithMessage("Unsupported MCP content block type: " ++ value)
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

@return(nullable)
@get
external uri: t => option<string> = "uri"

@return(nullable)
@get
external name: t => option<string> = "name"

@return(nullable)
@get
external description: t => option<string> = "description"

@return(nullable)
@get
external size: t => option<float> = "size"

@return(nullable)
@get
external resourceValue: t => option<McpResourceContents.t> = "resource"
