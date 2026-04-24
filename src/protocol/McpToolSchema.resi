type t
type kind = [#object]

let make: (~properties: dict<McpJsonValue.t>=?, ~required: array<string>=?, ()) => t
let kind: t => kind
let properties: t => option<dict<McpJsonValue.t>>
let required: t => option<array<string>>
