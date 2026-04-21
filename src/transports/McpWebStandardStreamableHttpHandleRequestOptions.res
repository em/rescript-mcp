// src/transports/McpWebStandardStreamableHttpHandleRequestOptions.res
// Concern: construct the extra options for a web-standard Streamable HTTP handleRequest call.
type t

@obj
external make: (~parsedBody: unknown=?, ~authInfo: McpAuthInfo.t=?, ()) => t = ""
