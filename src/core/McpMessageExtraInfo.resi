type t

let make: (
  ~request: Webapi.Fetch.Request.t=?,
  ~authInfo: McpAuthInfo.t=?,
  ~closeSSEStream: (unit => unit)=?,
  ~closeStandaloneSSEStream: (unit => unit)=?,
  unit,
) => t

let request: t => option<Webapi.Fetch.Request.t>
let authInfo: t => option<McpAuthInfo.t>
let closeSSEStream: t => option<unit => unit>
let closeStandaloneSSEStream: t => option<unit => unit>
