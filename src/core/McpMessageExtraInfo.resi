type t

let make: (
  ~requestInfo: McpRequestInfo.t=?,
  ~authInfo: McpAuthInfo.t=?,
  ~closeSSEStream: (unit => unit)=?,
  ~closeStandaloneSSEStream: (unit => unit)=?,
  unit,
) => t

let requestInfo: t => option<McpRequestInfo.t>
let authInfo: t => option<McpAuthInfo.t>
let closeSSEStream: t => option<unit => unit>
let closeStandaloneSSEStream: t => option<unit => unit>
