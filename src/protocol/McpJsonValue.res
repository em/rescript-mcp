// src/protocol/McpJsonValue.res
// Concern: model open MCP JSON payloads as an explicit ReScript algebra.
// Source: MCP protocol JSON payloads and schema-owned nested values carried through the installed SDK.
// Boundary: open JSON values stay in this package-owned union until a typed protocol wrapper or schema boundary classifies them further.
// Why this shape: the repo needs a truthful representation for caller-owned JSON that is still more precise than raw `unknown`.
// Coverage: tests/StandardSchema_test.res, tests/PublicWrapperCoverage_test.res
type rec t =
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | Array(array<t>)
  | Object(dict<t>)

let bool = value => Bool(value)
let int = value => Int(value)
let float = value => Float(value)
let string = value => String(value)
let array = value => Array(value)
let object = value => Object(value)

let rec toJSON = value =>
  switch value {
  | Null => JSON.Encode.null
  | Bool(raw) => JSON.Encode.bool(raw)
  | Int(raw) => JSON.Encode.int(raw)
  | Float(raw) => JSON.Encode.float(raw)
  | String(raw) => JSON.Encode.string(raw)
  | Array(items) => JSON.Encode.array(items->Array.map(toJSON))
  | Object(entries) =>
    let result = Dict.make()
    entries->Dict.toArray->Array.forEach(((key, item)) => result->Dict.set(key, item->toJSON))
    JSON.Encode.object(result)
  }
