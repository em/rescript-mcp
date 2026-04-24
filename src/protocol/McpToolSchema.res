// src/protocol/McpToolSchema.res
// Concern: construct and inspect the installed tool-schema object used by `tools/list` descriptors.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: the top-level schema kind is closed to `object`, while nested properties stay open at `dict<McpJsonValue.t>` because the package does not export full JSON Schema types.
// Why this shape: the SDK exposes a stable outer tool-schema object but leaves nested JSON Schema detail structurally open.
// Coverage: tests/BindingObjectSurface_test.res, tests/PublicWrapperCoverage_test.res
type t
type kind = [#object]

@obj
external makeRaw: (
  @as("type") ~kind: string,
  ~properties: dict<unknown>=?,
  ~required: array<string>=?,
  (),
) => t = ""

let make = (~properties=?, ~required=?, ()) => {
  let properties = properties->Option.map(McpJsonValueInterop.dictToUnknown)
  makeRaw(~kind="object", ~properties?, ~required?, ())
}

@get
external kindString: t => string = "type"

let kind = schema =>
  switch kindString(schema) {
  | "object" => #object
  | value => JsError.throwWithMessage("Unsupported MCP tool schema type: " ++ value)
  }

@return(nullable)
@get
external propertiesRaw: t => option<dict<unknown>> = "properties"

let properties = schema => schema->propertiesRaw->Option.map(McpJsonValueInterop.dictFromUnknownExn)

@return(nullable)
@get
external required: t => option<array<string>> = "required"
