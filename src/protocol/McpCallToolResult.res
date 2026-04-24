// src/protocol/McpCallToolResult.res
// Concern: expose the typed and raw public tool-result paths without conflating schema-classified output with heterogeneous JSON payloads.
// Source: `@modelcontextprotocol/{client,server}` tool result objects plus this package's typed Standard Schema bridge.
// Boundary: `t<'output>` is the typed public path, and `raw` is the explicit heterogeneous escape hatch.
// Why this shape: structured tool output is only trustworthy after schema classification, so the binding separates typed result records from raw runtime objects instead of hiding the distinction.
// Coverage: tests/AuthoringLifecycleRoundtrip_test.res, tests/ClientProtocolRoundtrip_test.res, tests/ExperimentalTasksRoundtrip_test.res, tests/PublicWrapperCoverage_test.res
type t<'output> = {
  content: array<McpContentBlock.t>,
  structuredContent: option<'output>,
  isError: option<bool>,
}
type raw

@obj
external makeJsRaw: (
  ~content: array<McpContentBlock.t>,
  ~structuredContent: dict<unknown>=?,
  ~isError: bool=?,
  (),
) => raw = ""

let make = (~content, ~structuredContent=?, ~isError=?, ()) => {
  content,
  structuredContent,
  isError,
}

let makeRaw = (~content, ~structuredContent=?, ~isError=?, ()) => {
  let structuredContent = structuredContent->Option.map(McpJsonValueInterop.dictToUnknown)
  makeJsRaw(~content, ~structuredContent?, ~isError?, ())
}

let content = result => result.content
let structuredContent = result => result.structuredContent
let isError = result => result.isError

@get
external contentRaw: raw => array<McpContentBlock.t> = "content"

@return(nullable)
@get
external structuredContentUnknown: raw => option<dict<unknown>> = "structuredContent"

let structuredContentRaw = result =>
  result->structuredContentUnknown->Option.map(McpJsonValueInterop.dictFromUnknownExn)

@return(nullable)
@get
external isErrorRaw: raw => option<bool> = "isError"
