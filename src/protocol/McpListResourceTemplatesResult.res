// src/protocol/McpListResourceTemplatesResult.res
// Concern: expose the installed `resources/templates/list` result object and resource-template descriptors.
type t
type resourceTemplate

@obj
external makeResourceTemplate: (
  ~uriTemplate: string,
  ~name: string,
  ~title: string=?,
  ~description: string=?,
  ~mimeType: string=?,
  ~annotations: McpAnnotations.t=?,
  ~_meta: dict<unknown>=?,
  ~icons: array<McpIcon.t>=?,
  (),
) => resourceTemplate = ""

@obj
external make: (
  ~resourceTemplates: array<resourceTemplate>,
  ~nextCursor: string=?,
  ~_meta: dict<unknown>=?,
  (),
) => t = ""

@get
external resourceTemplates: t => array<resourceTemplate> = "resourceTemplates"

@return(nullable)
@get
external nextCursor: t => option<string> = "nextCursor"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

@get
external uriTemplate: resourceTemplate => string = "uriTemplate"

@get
external name: resourceTemplate => string = "name"

@return(nullable)
@get
external title: resourceTemplate => option<string> = "title"

@return(nullable)
@get
external description: resourceTemplate => option<string> = "description"

@return(nullable)
@get
external mimeType: resourceTemplate => option<string> = "mimeType"

@return(nullable)
@get
external annotations: resourceTemplate => option<McpAnnotations.t> = "annotations"

@return(nullable)
@get
external resourceTemplateMeta: resourceTemplate => option<dict<unknown>> = "_meta"

@return(nullable)
@get
external icons: resourceTemplate => option<array<McpIcon.t>> = "icons"
