// src/transports/McpNodeStreamableHttpServerTransportOptions.resi
// Concern: expose the installed node Streamable HTTP transport-options alias under its upstream package name.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: this signature is the same runtime options object as the web-standard transport-options module.
// Why this shape: the installed SDK exports an alias here, so the binding mirrors the alias instead of inventing a second options record.
// Coverage: tests/BindingObjectSurface_test.res, tests/PublicWrapperCoverage_test.res
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
  ~supportedProtocolVersions: array<McpProtocolVersion.t>=?,
  unit,
) => t
