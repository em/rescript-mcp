// src/protocol/McpElicitRequestFormParams.res
// Concern: expose the ordinary form-based elicitation request params.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts` `ElicitRequestFormParams`.
// Boundary: typed public subset with an explicit open requested-schema seam.
// Why this shape: the request envelope is fixed, but the requested form schema remains a caller-owned JSON
// schema fragment, so the binding keeps only that leaf open instead of widening the whole request object.
// Coverage: tests/LowLevelCallbackRoundtrip_test.res, tests/AuthoringLifecycleRoundtrip_test.res
type t

@obj
external make: (~message: string, ~requestedSchema: dict<unknown>, ~_meta: dict<unknown>=?, ()) => t = ""

@get
external message: t => string = "message"

@get
external requestedSchema: t => dict<unknown> = "requestedSchema"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
