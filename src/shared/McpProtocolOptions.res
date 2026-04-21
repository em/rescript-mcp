// src/shared/McpProtocolOptions.res
// Concern: construct the schema-independent protocol options shared by client and server constructors.
type t

@obj
external make: (
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~taskStore: unknown=?,
  ~taskMessageQueue: unknown=?,
  ~defaultTaskPollInterval: int=?,
  ~maxTaskQueueSize: int=?,
  (),
) => t = ""
