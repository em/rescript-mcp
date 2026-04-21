type t

let make: (
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~taskStore: unknown=?,
  ~taskMessageQueue: unknown=?,
  ~defaultTaskPollInterval: int=?,
  ~maxTaskQueueSize: int=?,
  unit,
) => t
