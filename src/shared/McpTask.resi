type t

let taskId: t => string
let status: t => McpTaskStatus.t
let ttl: t => option<int>
let createdAt: t => string
let lastUpdatedAt: t => string
let pollInterval: t => option<int>
let statusMessage: t => option<string>
