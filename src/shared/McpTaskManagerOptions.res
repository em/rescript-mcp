// src/shared/McpTaskManagerOptions.res
// Concern: construct task-manager runtime options shared by client and server constructors.
type t

@obj
external make: (
  ~taskStore: McpTaskStore.t=?,
  ~taskMessageQueue: McpTaskMessageQueue.t=?,
  ~defaultTaskPollInterval: int=?,
  ~maxTaskQueueSize: int=?,
  (),
) => t = ""
