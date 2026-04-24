// src/transports/McpWebStandardStreamableHttpServerTransportOptions.res
// Concern: construct web-standard Streamable HTTP server transport options.
type t

@obj
external makeRaw: (
  ~sessionIdGenerator: (unit => string)=?,
  ~onsessioninitialized: (string => unit)=?,
  ~onsessionclosed: (string => unit)=?,
  ~enableJsonResponse: bool=?,
  ~eventStore: unknown=?,
  ~allowedHosts: array<string>=?,
  ~allowedOrigins: array<string>=?,
  ~enableDnsRebindingProtection: bool=?,
  ~retryInterval: int=?,
  ~supportedProtocolVersions: array<string>=?,
  (),
) => t = ""

let make = (~sessionIdGenerator=?, ~onsessioninitialized=?, ~onsessionclosed=?, ~enableJsonResponse=?, ~eventStore=?, ~allowedHosts=?, ~allowedOrigins=?, ~enableDnsRebindingProtection=?, ~retryInterval=?, ~supportedProtocolVersions=?, ()) => {
  let supportedProtocolVersions =
    supportedProtocolVersions->Option.map(versions => versions->Array.map(McpProtocolVersion.toString))
  makeRaw(~sessionIdGenerator?, ~onsessioninitialized?, ~onsessionclosed?, ~enableJsonResponse?, ~eventStore?, ~allowedHosts?, ~allowedOrigins?, ~enableDnsRebindingProtection?, ~retryInterval?, ~supportedProtocolVersions?, ())
}
