// src/transports/McpWebStandardStreamableHttpServerTransportOptions.res
// Concern: construct web-standard Streamable HTTP server transport options.
type t

@obj
external make: (
  ~sessionIdGenerator: (unit => string)=?,
  ~onsessioninitialized: (string => unit)=?,
  ~onsessionclosed: (string => unit)=?,
  ~enableJsonResponse: bool=?,
  ~eventStore: unknown=?,
  ~allowedHosts: array<string>=?,
  ~allowedOrigins: array<string>=?,
  ~enableDnsRebindingProtection: bool=?,
  ~retryInterval: int=?,
  (),
) => t = ""
