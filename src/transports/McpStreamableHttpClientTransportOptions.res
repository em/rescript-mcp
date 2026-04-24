// src/transports/McpStreamableHttpClientTransportOptions.res
// Concern: construct Streamable HTTP client transport options.
type t

@obj
external makeRaw: (
  ~authProvider: unknown=?,
  ~requestInit: Webapi.Fetch.requestInit=?,
  ~fetch: unknown=?,
  ~reconnectionOptions: McpStreamableHttpReconnectionOptions.t=?,
  ~reconnectionScheduler: unknown=?,
  ~sessionId: string=?,
  ~protocolVersion: string=?,
  (),
) => t = ""

let make = (~authProvider=?, ~requestInit=?, ~fetch=?, ~reconnectionOptions=?, ~reconnectionScheduler=?, ~sessionId=?, ~protocolVersion=?, ()) => {
  let protocolVersion = protocolVersion->Option.map(McpProtocolVersion.toString)
  makeRaw(~authProvider?, ~requestInit?, ~fetch?, ~reconnectionOptions?, ~reconnectionScheduler?, ~sessionId?, ~protocolVersion?, ())
}
