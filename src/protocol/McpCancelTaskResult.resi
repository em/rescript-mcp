type t

let make: (
  ~taskId: string,
  ~status: McpTaskStatus.t,
  ~ttl: int=?,
  ~createdAt: string,
  ~lastUpdatedAt: string,
  ~pollInterval: int=?,
  ~statusMessage: string=?,
  unit,
) => t
let ofTask: McpTask.t => t
let taskId: t => string
let status: t => McpTaskStatus.t
let ttl: t => option<int>
let createdAt: t => string
let lastUpdatedAt: t => string
let pollInterval: t => option<int>
let statusMessage: t => option<string>
