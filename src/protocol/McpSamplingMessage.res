// src/protocol/McpSamplingMessage.res
// Concern: construct ordinary sampling request history messages for the typed public subset.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts` `SamplingMessage`.
// Boundary: typed public subset with a role plus either one ordinary sampling block or an array of them.
// Why this shape: the installed request schema also allows tool-use and tool-result message blocks. The
// binding keeps the ordinary text-image-audio path typed here and leaves the wider sampling-message block
// union on the explicit raw path until those variants are bound directly.
// Coverage: tests/LowLevelCallbackRoundtrip_test.res, tests/AuthoringLifecycleRoundtrip_test.res
type t
type content = [#single(McpSamplingContent.t) | #multiple(array<McpSamplingContent.t>)]

@obj
external makeSingle: (~role: McpPromptMessage.role, ~content: McpSamplingContent.t, ()) => t = ""

@obj
external makeMany: (~role: McpPromptMessage.role, ~content: array<McpSamplingContent.t>, ()) => t = ""

let text = (~role, ~text) => makeSingle(~role, ~content=McpSamplingContent.text(text), ())

@get
external role: t => McpPromptMessage.role = "role"

@get
external contentUnknown: t => unknown = "content"

@get
external contentSingle: t => McpSamplingContent.t = "content"

@get
external contentMany: t => array<McpSamplingContent.t> = "content"

@scope("Array")
@val
external isArray: unknown => bool = "isArray"

let content = message =>
  if contentUnknown(message)->isArray {
    #multiple(contentMany(message))
  } else {
    #single(contentSingle(message))
  }
