type t
type kind = [#text | #image | #audio | #resourceLink | #resource]

let text: string => t
let image: (~data: string, ~mimeType: string) => t
let audio: (~data: string, ~mimeType: string) => t
let resourceLink: (
  ~uri: string,
  ~name: string,
  ~description: string=?,
  ~mimeType: string=?,
  ~size: float=?,
) => t
let resource: McpResourceContents.t => t

let kind: t => kind
let textValue: t => option<string>
let data: t => option<string>
let mimeType: t => option<string>
let uri: t => option<string>
let name: t => option<string>
let description: t => option<string>
let size: t => option<float>
let resourceValue: t => option<McpResourceContents.t>
