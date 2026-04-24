type t

let make: (~task: McpTask.t, unit) => t
let task: t => McpTask.t
