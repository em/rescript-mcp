// src/protocol/McpCallToolResultInternal.res
// Concern: convert between the public typed tool-result record and the raw SDK tool-result object through `McpStandardSchema`.
// Source: package-owned typed tool-result surface layered over upstream raw SDK result objects.
// Boundary: this module owns the runtime classification step that turns typed structured content into raw objects and back.
// Why this shape: the typed public path must serialize and parse structured content through the same schema object or the `'output` claim becomes dishonest.
// Coverage: tests/ClientProtocolRoundtrip_test.res, tests/ExperimentalTasksRoundtrip_test.res, tests/PublicWrapperCoverage_test.res, tests/CompileShape_test.res
@obj
external makeRaw: (
  ~content: array<McpContentBlock.t>,
  ~structuredContent: dict<unknown>=?,
  ~isError: bool=?,
  (),
) => McpCallToolResult.raw = ""

@get
external content: McpCallToolResult.t<'output> => array<McpContentBlock.t> = "content"

@return(nullable)
@get
external structuredContent: McpCallToolResult.t<'output> => option<'output> = "structuredContent"

@return(nullable)
@get
external isError: McpCallToolResult.t<'output> => option<bool> = "isError"

let toRaw = (result: McpCallToolResult.t<'output>, outputSchema: McpStandardSchema.t<'output>) => {
  let structuredContent =
    result->structuredContent->Option.map(value =>
      outputSchema->McpStandardSchemaInternal.objectFromValueOrThrow(value)
    )
  let content = result->content
  let isError = result->isError
  makeRaw(~content, ~structuredContent?, ~isError?, ())
}

let fromRaw = (result: McpCallToolResult.raw, outputSchema: McpStandardSchema.t<'output>) => {
  let structuredContent =
    result
    ->McpCallToolResult.structuredContentRaw
    ->Option.map(raw => outputSchema->McpStandardSchemaInternal.valueFromObjectOrThrow(raw))
  let isError = result->McpCallToolResult.isErrorRaw
  McpCallToolResult.make(
    ~content=result->McpCallToolResult.contentRaw,
    ~structuredContent?,
    ~isError?,
    (),
  )
}
