type t = McpTransport.t

let make: Webapi.Url.t => t
let makeWithOptions: (Webapi.Url.t, McpStreamableHttpClientTransportOptions.t) => t
let finishAuth: (t, string) => promise<unit>
let terminateSession: t => promise<unit>
let setProtocolVersion: (t, string) => unit
let protocolVersion: t => option<string>
