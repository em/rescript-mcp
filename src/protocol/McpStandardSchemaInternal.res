// src/protocol/McpStandardSchemaInternal.res
// Concern: perform the runtime value conversion that the public Standard Schema bridge uses for typed structured tool output.
// Source: package-owned `McpStandardSchema.t<'value>` values produced from `rescript-schema`.
// Boundary: this internal module is the only place that turns typed structured content into raw JS objects and parses raw objects back into typed values.
// Why this shape: tool structured content must round-trip through the same schema instance, and MCP tool results only admit object-shaped structured content.
// Coverage: tests/ClientProtocolRoundtrip_test.res, tests/ExperimentalTasksRoundtrip_test.res, tests/PublicWrapperCoverage_test.res, tests/CompileShape_test.res
module Schema = RescriptSchema.S

@get
external rescriptSchema: McpStandardSchema.t<'value> => Schema.t<'value> = "__rescriptSchema"

external asNullable: unknown => Nullable.t<unknown> = "%identity"
external asDict: unknown => dict<unknown> = "%identity"

let unsupportedStructuredContent = kind =>
  JsError.throwWithMessage("Structured content must convert to an object, got " ++ kind)

let objectFromValueOrThrow = (schema: McpStandardSchema.t<'value>, value: 'value) => {
  let raw = Schema.reverseConvertOrThrow(value, schema->rescriptSchema)
  switch typeof(raw) {
  | #object =>
    if Nullable.isNullable(asNullable(raw)) {
      unsupportedStructuredContent("null")
    } else if Array.isArray(raw) {
      unsupportedStructuredContent("array")
    } else {
      asDict(raw)
    }
  | #string => unsupportedStructuredContent("string")
  | #boolean => unsupportedStructuredContent("boolean")
  | #number => unsupportedStructuredContent("number")
  | #undefined => unsupportedStructuredContent("undefined")
  | #bigint => unsupportedStructuredContent("bigint")
  | #function => unsupportedStructuredContent("function")
  | #symbol => unsupportedStructuredContent("symbol")
  }
}

let valueFromObjectOrThrow = (schema: McpStandardSchema.t<'value>, raw: dict<McpJsonValue.t>) =>
  Schema.parseOrThrow(raw->McpJsonValueInterop.dictToUnknown, schema->rescriptSchema)
