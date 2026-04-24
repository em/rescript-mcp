// src/transports/McpSSEClientTransportOptions.res
// Concern: construct SSE client transport options.
type t

@obj
external make: (
  ~authProvider: unknown=?,
  ~eventSourceInit: unknown=?,
  ~requestInit: Webapi.Fetch.requestInit=?,
  ~fetch: unknown=?,
  (),
) => t = ""
