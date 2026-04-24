type t

let make: (
  ~taskStore: McpTaskStore.t=?,
  ~taskMessageQueue: McpTaskMessageQueue.t=?,
  ~defaultTaskPollInterval: int=?,
  ~maxTaskQueueSize: int=?,
  unit,
) => t
