type t

let make: (
  ~authProvider: unknown=?,
  ~requestInit: Webapi.Fetch.requestInit=?,
  ~fetch: unknown=?,
  ~reconnectionOptions: McpStreamableHttpReconnectionOptions.t=?,
  ~reconnectionScheduler: unknown=?,
  ~sessionId: string=?,
  ~protocolVersion: McpProtocolVersion.t=?,
  unit,
) => t
