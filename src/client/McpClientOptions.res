// src/client/McpClientOptions.res
// Concern: construct high-level client options.
type t

@obj
external make: (
  ~capabilities: dict<unknown>=?,
  ~jsonSchemaValidator: unknown=?,
  ~listChanged: unknown=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~taskStore: unknown=?,
  ~taskMessageQueue: unknown=?,
  ~defaultTaskPollInterval: int=?,
  ~maxTaskQueueSize: int=?,
  (),
) => t = ""
