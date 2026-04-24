type t

let make: (~messages: array<McpPromptMessage.t>, ~description: string=?, ()) => t
let messages: t => array<McpPromptMessage.t>
let description: t => option<string>
