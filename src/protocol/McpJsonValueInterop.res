// src/protocol/McpJsonValueInterop.res
// Concern: convert between raw JavaScript values and the package-owned `McpJsonValue.t` algebra.
// Source: JavaScript runtime values crossing the MCP SDK boundary.
// Boundary: `%identity` is confined here because this module owns the `unknown` to `McpJsonValue.t` conversion seam.
// Why this shape: JSON-shaped runtime values arrive as plain JS objects and arrays, so the binding needs one audited conversion module instead of duplicating casts across the package.
// Coverage: tests/StandardSchema_test.res, tests/ClientProtocolRoundtrip_test.res, tests/PublicWrapperCoverage_test.res
external asNullable: unknown => Nullable.t<unknown> = "%identity"
external asString: unknown => string = "%identity"
external asBool: unknown => bool = "%identity"
external asFloat: unknown => float = "%identity"
external asInt: unknown => int = "%identity"
external asArray: unknown => array<unknown> = "%identity"
external asDict: unknown => dict<unknown> = "%identity"
external stringToUnknown: string => unknown = "%identity"
external boolToUnknown: bool => unknown = "%identity"
external floatToUnknown: float => unknown = "%identity"
external intToUnknown: int => unknown = "%identity"
external arrayToUnknown: array<unknown> => unknown = "%identity"
external dictToUnknown: dict<unknown> => unknown = "%identity"
external jsonToUnknown: JSON.t => unknown = "%identity"

let invalidJsonValue = kind =>
  JsError.throwWithMessage(`Unsupported MCP JSON value at runtime: ${kind}`)

let rec fromUnknownExn = raw =>
  switch typeof(raw) {
  | #string => McpJsonValue.String(asString(raw))
  | #boolean => McpJsonValue.Bool(asBool(raw))
  | #number =>
    let value = asFloat(raw)
    if Math.floor(value) == value && value >= -2147483648.0 && value <= 2147483647.0 {
      McpJsonValue.Int(asInt(raw))
    } else {
      McpJsonValue.Float(value)
    }
  | #object =>
    if Nullable.isNullable(asNullable(raw)) {
      McpJsonValue.Null
    } else if Array.isArray(raw) {
      McpJsonValue.Array(asArray(raw)->Array.map(fromUnknownExn))
    } else {
      let result = Dict.make()
      asDict(raw)
      ->Dict.toArray
      ->Array.forEach(((key, value)) => result->Dict.set(key, fromUnknownExn(value)))
      McpJsonValue.Object(result)
    }
  | #undefined => invalidJsonValue("undefined")
  | #bigint => invalidJsonValue("bigint")
  | #function => invalidJsonValue("function")
  | #symbol => invalidJsonValue("symbol")
  }

let dictFromUnknownExn = raw => {
  let result = Dict.make()
  raw->Dict.toArray->Array.forEach(((key, value)) => result->Dict.set(key, fromUnknownExn(value)))
  result
}
let rec toUnknown = value =>
  switch value {
  | McpJsonValue.Null => JSON.Encode.null->jsonToUnknown
  | McpJsonValue.Bool(raw) => boolToUnknown(raw)
  | McpJsonValue.Int(raw) => intToUnknown(raw)
  | McpJsonValue.Float(raw) => floatToUnknown(raw)
  | McpJsonValue.String(raw) => stringToUnknown(raw)
  | McpJsonValue.Array(items) => items->Array.map(toUnknown)->arrayToUnknown
  | McpJsonValue.Object(entries) => dictToUnknownObject(entries)
  }

and dictToUnknownObject = entries => {
  let result = Dict.make()
  entries->Dict.toArray->Array.forEach(((key, value)) => result->Dict.set(key, toUnknown(value)))
  result->dictToUnknown
}

let dictToUnknown = entries => {
  let result = Dict.make()
  entries->Dict.toArray->Array.forEach(((key, value)) => result->Dict.set(key, toUnknown(value)))
  result
}
