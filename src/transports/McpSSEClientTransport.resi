type t = McpTransport.t

let make: Webapi.Url.t => t
let makeWithOptions: (Webapi.Url.t, McpSSEClientTransportOptions.t) => t
let finishAuth: (t, string) => promise<unit>
let setProtocolVersion: (t, McpProtocolVersion.t) => unit
