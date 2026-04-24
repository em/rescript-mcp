type t
type resourceTemplate

let makeResourceTemplate: (
  ~uriTemplate: string,
  ~name: string,
  ~title: string=?,
  ~description: string=?,
  ~mimeType: string=?,
  ~annotations: McpAnnotations.t=?,
  ~_meta: dict<unknown>=?,
  ~icons: array<McpIcon.t>=?,
  (),
) => resourceTemplate
let make: (
  ~resourceTemplates: array<resourceTemplate>,
  ~nextCursor: string=?,
  ~_meta: dict<unknown>=?,
  (),
) => t
let resourceTemplates: t => array<resourceTemplate>
let nextCursor: t => option<string>
let meta: t => option<dict<unknown>>
let uriTemplate: resourceTemplate => string
let name: resourceTemplate => string
let title: resourceTemplate => option<string>
let description: resourceTemplate => option<string>
let mimeType: resourceTemplate => option<string>
let annotations: resourceTemplate => option<McpAnnotations.t>
let resourceTemplateMeta: resourceTemplate => option<dict<unknown>>
let icons: resourceTemplate => option<array<McpIcon.t>>
