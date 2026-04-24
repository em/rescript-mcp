type t
type stopReason = [#maxTokens | #endTurn | #stopSequence | #other(string)]

let make: (
  ~model: string,
  ~role: McpPromptMessage.role,
  ~content: McpSamplingContent.t,
  ~stopReason: stopReason=?,
  ~_meta: dict<unknown>=?,
  (),
) => t

let model: t => string
let role: t => McpPromptMessage.role
let content: t => McpSamplingContent.t
let stopReason: t => option<stopReason>
let meta: t => option<dict<unknown>>
