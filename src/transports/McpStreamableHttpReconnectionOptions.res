// src/transports/McpStreamableHttpReconnectionOptions.res
// Concern: construct reconnection options for the Streamable HTTP client transport.
type t

@obj
external make: (
  ~maxReconnectionDelay: int,
  ~initialReconnectionDelay: int,
  ~reconnectionDelayGrowFactor: float,
  ~maxRetries: int,
) => t = ""
