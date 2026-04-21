type t = McpWebStandardStreamableHttpServerTransportOptions.t

let make: (
  ~sessionIdGenerator: (unit => string)=?,
  ~onsessioninitialized: (string => unit)=?,
  ~onsessionclosed: (string => unit)=?,
  ~enableJsonResponse: bool=?,
  ~eventStore: unknown=?,
  ~allowedHosts: array<string>=?,
  ~allowedOrigins: array<string>=?,
  ~enableDnsRebindingProtection: bool=?,
  ~retryInterval: int=?,
  unit,
) => t
