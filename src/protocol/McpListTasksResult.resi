type t

let make: (
  ~tasks: array<McpTask.t>,
  ~nextCursor: string=?,
  unit,
) => t
let tasks: t => array<McpTask.t>
let nextCursor: t => option<string>
