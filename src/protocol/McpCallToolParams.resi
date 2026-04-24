type t

let make: (
  ~name: string,
  ~argumentValues: dict<McpJsonValue.t>=?,
  ~task: McpCreateTaskOptions.t=?,
  ~_meta: dict<unknown>=?,
  (),
) => t
let name: t => string
let argumentValues: t => option<dict<McpJsonValue.t>>
let task: t => option<McpCreateTaskOptions.t>
let meta: t => option<dict<unknown>>
