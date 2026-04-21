type t

let make: (
  ~authProvider: unknown=?,
  ~requestInit: Webapi.Fetch.requestInit=?,
  ~fetch: unknown=?,
  ~reconnectionOptions: McpStreamableHttpReconnectionOptions.t=?,
  ~sessionId: string=?,
  unit,
) => t
