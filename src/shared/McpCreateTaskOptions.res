// src/shared/McpCreateTaskOptions.res
// Concern: construct task-store create options for task-based server handlers.
type t

@obj
external make: (
  ~ttl: int=?,
  ~pollInterval: int=?,
  ~context: dict<unknown>=?,
  (),
) => t = ""
