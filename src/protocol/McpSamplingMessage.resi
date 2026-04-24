type t
type content = [#single(McpSamplingContent.t) | #multiple(array<McpSamplingContent.t>)]

let makeSingle: (~role: McpPromptMessage.role, ~content: McpSamplingContent.t, ()) => t
let makeMany: (~role: McpPromptMessage.role, ~content: array<McpSamplingContent.t>, ()) => t
let text: (~role: McpPromptMessage.role, ~text: string) => t
let role: t => McpPromptMessage.role
let content: t => content
