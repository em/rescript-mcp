// src/core/McpProtocolVersion.res
// Concern: classify the finite MCP protocol versions shipped by the installed SDK line.
// Source: `node_modules/@modelcontextprotocol/{client,server}/dist/index-*.d.mts` and `src-*.mjs`.
// Boundary: public protocol-version control surfaces use this finite algebra instead of raw strings.
// Why this shape: the installed SDK ships a closed supported-version list, so the binding should expose those versions as a real type and keep string conversion at the boundary.
// Coverage: tests/ProtocolSurface_test.res, tests/BindingObjectSurface_test.res, tests/HttpRoundtrip_test.res, tests/WebStandardRequestResponse_test.res
type t = [#v2024_10_07 | #v2024_11_05 | #v2025_03_26 | #v2025_06_18 | #v2025_11_25]

let toString = version =>
  switch version {
  | #v2024_10_07 => "2024-10-07"
  | #v2024_11_05 => "2024-11-05"
  | #v2025_03_26 => "2025-03-26"
  | #v2025_06_18 => "2025-06-18"
  | #v2025_11_25 => "2025-11-25"
  }

let fromString = version =>
  switch version {
  | "2024-10-07" => #v2024_10_07
  | "2024-11-05" => #v2024_11_05
  | "2025-03-26" => #v2025_03_26
  | "2025-06-18" => #v2025_06_18
  | "2025-11-25" => #v2025_11_25
  | value => JsError.throwWithMessage("Unsupported MCP protocol version: " ++ value)
  }

let latest = #v2025_11_25
let defaultNegotiated = #v2025_03_26
let supported = [#v2025_11_25, #v2025_06_18, #v2025_03_26, #v2024_11_05, #v2024_10_07]
