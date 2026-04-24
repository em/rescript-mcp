// src/protocol/McpElicitResult.res
// Concern: expose the client's elicitation response object.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts` `ElicitResult`.
// Boundary: fixed action discriminator with a schema-owned response-content leaf.
// Why this shape: the SDK fixes the outer result object and action enum, but the accepted content shape
// depends on the request's caller-owned form schema, so only that leaf stays open.
// Coverage: tests/LowLevelCallbackRoundtrip_test.res, tests/AuthoringLifecycleRoundtrip_test.res
type t
type action = [#cancel | #accept | #decline]

@obj
external makeInternal: (~action: string, ~content: dict<unknown>=?, ~_meta: dict<unknown>=?, ()) => t = ""

@get
external actionRaw: t => string = "action"

let action = result =>
  switch actionRaw(result) {
  | "cancel" => #cancel
  | "accept" => #accept
  | "decline" => #decline
  | value => JsError.throwWithMessage("Unsupported MCP elicitation action: " ++ value)
  }

@return(nullable)
@get
external content: t => option<dict<unknown>> = "content"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

let make = (~action, ~content=?, ~_meta=?, ()) => {
  let actionString = switch action {
  | #cancel => "cancel"
  | #accept => "accept"
  | #decline => "decline"
  }
  makeInternal(~action=actionString, ~content?, ~_meta?, ())
}
