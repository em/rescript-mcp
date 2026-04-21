type t = McpTransport.t

let make: unit => t
let makeWithOptions: McpNodeStreamableHttpServerTransportOptions.t => t
let handleRequest: (
  t,
  NodeJs.Http.IncomingMessage.t,
  NodeJs.Http.ServerResponse.t,
) => promise<unit>
let handleRequestWithParsedBody: (
  t,
  NodeJs.Http.IncomingMessage.t,
  NodeJs.Http.ServerResponse.t,
  unknown,
) => promise<unit>
let closeSSEStream: (t, unknown) => unit
let closeStandaloneSSEStream: t => unit
