type t = McpTransport.t

let make: unit => t
let makeWithOptions: McpWebStandardStreamableHttpServerTransportOptions.t => t
let handleRequest: (t, Webapi.Fetch.request) => promise<Webapi.Fetch.response>
let handleRequestWithOptions: (
  t,
  Webapi.Fetch.request,
  McpWebStandardStreamableHttpHandleRequestOptions.t,
) => promise<Webapi.Fetch.response>
let closeSSEStream: (t, unknown) => unit
let closeStandaloneSSEStream: t => unit
