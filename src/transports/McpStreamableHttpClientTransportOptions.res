// src/transports/McpStreamableHttpClientTransportOptions.res
// Concern: construct Streamable HTTP client transport options.
type t

@obj
external make: (
  ~authProvider: unknown=?,
  ~requestInit: Webapi.Fetch.requestInit=?,
  ~fetch: unknown=?,
  ~reconnectionOptions: McpStreamableHttpReconnectionOptions.t=?,
  ~sessionId: string=?,
  (),
) => t = ""
