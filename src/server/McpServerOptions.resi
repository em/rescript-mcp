type t

let make: (
  ~capabilities: dict<unknown>=?,
  ~instructions: string=?,
  ~jsonSchemaValidator: unknown=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~taskStore: unknown=?,
  ~taskMessageQueue: unknown=?,
  ~defaultTaskPollInterval: int=?,
  ~maxTaskQueueSize: int=?,
  unit,
) => t
