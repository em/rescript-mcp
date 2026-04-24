// src/protocol/McpCreateMessageResult.res
// Concern: expose the exact no-tools sampling result returned by the client.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts` `CreateMessageResult`.
// Boundary: typed public result object for ordinary no-tools sampling requests.
// Why this shape: the installed SDK uses a narrower text-image-audio result on the no-tools overload, so
// the binding preserves that exact result instead of widening it to the tool-enabled response union.
// Coverage: tests/LowLevelCallbackRoundtrip_test.res
type t
type stopReason = [#maxTokens | #endTurn | #stopSequence | #other(string)]

@obj
external makeInternal: (
  ~model: string,
  ~role: McpPromptMessage.role,
  ~content: McpSamplingContent.t,
  ~stopReason: string=?,
  ~_meta: dict<unknown>=?,
  (),
) => t = ""

@get
external model: t => string = "model"

@get
external role: t => McpPromptMessage.role = "role"

@get
external content: t => McpSamplingContent.t = "content"

@return(nullable)
@get
external stopReasonRaw: t => option<string> = "stopReason"

let stopReason = result =>
  switch stopReasonRaw(result) {
  | Some("maxTokens") => Some(#maxTokens)
  | Some("endTurn") => Some(#endTurn)
  | Some("stopSequence") => Some(#stopSequence)
  | Some(value) => Some(#other(value))
  | None => None
  }

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

let make = (~model, ~role, ~content, ~stopReason=?, ~_meta=?, ()) => {
  let stopReason = switch stopReason {
  | Some(#maxTokens) => Some("maxTokens")
  | Some(#endTurn) => Some("endTurn")
  | Some(#stopSequence) => Some("stopSequence")
  | Some(#other(value)) => Some(value)
  | None => None
  }
  makeInternal(~model, ~role, ~content, ~stopReason?, ~_meta?, ())
}
