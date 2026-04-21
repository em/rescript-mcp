type t

let make: (
  ~maxReconnectionDelay: int,
  ~initialReconnectionDelay: int,
  ~reconnectionDelayGrowFactor: float,
  ~maxRetries: int,
) => t
