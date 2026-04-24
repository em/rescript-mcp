type t
type resource

let makeResource: (
  ~uri: string,
  ~name: string,
  ~title: string=?,
  ~description: string=?,
  ~mimeType: string=?,
  ~size: float=?,
  ~annotations: McpAnnotations.t=?,
  ~_meta: dict<unknown>=?,
  ~icons: array<McpIcon.t>=?,
  (),
) => resource
let make: (~resources: array<resource>, ~nextCursor: string=?, ~_meta: dict<unknown>=?, ()) => t
let resources: t => array<resource>
let nextCursor: t => option<string>
let meta: t => option<dict<unknown>>
let uri: resource => string
let name: resource => string
let title: resource => option<string>
let description: resource => option<string>
let mimeType: resource => option<string>
let size: resource => option<float>
let annotations: resource => option<McpAnnotations.t>
let resourceMeta: resource => option<dict<unknown>>
let icons: resource => option<array<McpIcon.t>>
