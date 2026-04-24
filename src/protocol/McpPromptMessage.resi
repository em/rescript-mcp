type t
type role = [#assistant | #user]

let make: (~role: role, ~content: McpContentBlock.t) => t
let text: (~role: role, ~text: string) => t
let role: t => role
let content: t => McpContentBlock.t
