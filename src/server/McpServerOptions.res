// src/server/McpServerOptions.res
// Concern: construct low-level and high-level server options.
type t

@obj
external make: (
  ~capabilities: dict<unknown>=?,
  ~instructions: string=?,
  ~jsonSchemaValidator: unknown=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~taskStore: unknown=?,
  ~taskMessageQueue: unknown=?,
  ~defaultTaskPollInterval: int=?,
  ~maxTaskQueueSize: int=?,
  (),
) => t = ""
