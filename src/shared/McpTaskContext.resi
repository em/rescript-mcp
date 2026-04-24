type t

let id: t => option<string>
let store: t => McpRequestTaskStore.t
let requestedTtl: t => option<int>
