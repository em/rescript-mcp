// src/protocol/McpCallToolParams.res
// Concern: construct and inspect the installed `tools/call` params object on the public binding surface.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts`.
// Boundary: the outer request object is typed, but tool argument values stay open as `dict<McpJsonValue.t>` because tool inputs are caller-owned payloads.
// Why this shape: the SDK fixes the `tools/call` request shape while leaving argument payload structure open until an app schema classifies it.
// Coverage: tests/ClientProtocolRoundtrip_test.res, tests/PublicWrapperCoverage_test.res
type t

@obj
external makeRaw: (
  ~name: string,
  @as("arguments") ~argumentValues: dict<unknown>=?,
  ~task: McpCreateTaskOptions.t=?,
  ~_meta: dict<unknown>=?,
  (),
) => t = ""

let make = (~name, ~argumentValues=?, ~task=?, ~_meta=?, ()) => {
  let argumentValues = argumentValues->Option.map(McpJsonValueInterop.dictToUnknown)
  makeRaw(~name, ~argumentValues?, ~task?, ~_meta?, ())
}

@get
external name: t => string = "name"

@return(nullable)
@get
external argumentValuesRaw: t => option<dict<unknown>> = "arguments"

let argumentValues = params => params->argumentValuesRaw->Option.map(McpJsonValueInterop.dictFromUnknownExn)

@return(nullable)
@get
external task: t => option<McpCreateTaskOptions.t> = "task"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
