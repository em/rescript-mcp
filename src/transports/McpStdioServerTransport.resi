type t = McpTransport.t

let make: unit => t
let makeWithStreams: (
  NodeJs.Stream.Readable.t<NodeJs.Buffer.t>,
  NodeJs.Stream.Writable.t<NodeJs.Buffer.t>,
) => t
