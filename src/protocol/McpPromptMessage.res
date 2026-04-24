// src/protocol/McpPromptMessage.res
// Concern: construct prompt messages returned by high-level prompt handlers.
type t
type role = [#assistant | #user]

@obj
external make: (~role: role, ~content: McpContentBlock.t) => t = ""

let text = (~role, ~text) => make(~role, ~content=McpContentBlock.text(text))

@get
external role: t => role = "role"

@get
external content: t => McpContentBlock.t = "content"
