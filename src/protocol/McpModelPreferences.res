// src/protocol/McpModelPreferences.res
// Concern: expose the finite model-preference object used by sampling requests.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts` `ModelPreferences`.
// Boundary: public protocol payload with exact optional numeric priorities and name hints.
// Why this shape: the installed SDK exports a fixed object rather than an open dictionary, so the binding
// keeps the priorities and hint records typed instead of routing them through `unknown`.
// Coverage: tests/LowLevelCallbackRoundtrip_test.res, tests/AuthoringLifecycleRoundtrip_test.res
type t
type hint

@obj
external makeHint: (~name: string=?, ()) => hint = ""

@obj
external make: (
  ~hints: array<hint>=?,
  ~costPriority: float=?,
  ~speedPriority: float=?,
  ~intelligencePriority: float=?,
  (),
) => t = ""

@return(nullable)
@get
external hints: t => option<array<hint>> = "hints"

@return(nullable)
@get
external costPriority: t => option<float> = "costPriority"

@return(nullable)
@get
external speedPriority: t => option<float> = "speedPriority"

@return(nullable)
@get
external intelligencePriority: t => option<float> = "intelligencePriority"

@return(nullable)
@get
external hintName: hint => option<string> = "name"
