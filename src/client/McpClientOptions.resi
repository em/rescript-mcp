type t

let make: (
  ~capabilities: dict<unknown>=?,
  ~jsonSchemaValidator: unknown=?,
  ~listChanged: unknown=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~taskStore: unknown=?,
  ~taskMessageQueue: unknown=?,
  ~defaultTaskPollInterval: int=?,
  ~maxTaskQueueSize: int=?,
  unit,
) => t
