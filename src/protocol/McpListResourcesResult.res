// src/protocol/McpListResourcesResult.res
// Concern: expose the installed `resources/list` result object and resource descriptors.
type t
type resource

@obj
external makeResource: (
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
) => resource = ""

@obj
external make: (~resources: array<resource>, ~nextCursor: string=?, ~_meta: dict<unknown>=?, ()) => t =
  ""

@get
external resources: t => array<resource> = "resources"

@return(nullable)
@get
external nextCursor: t => option<string> = "nextCursor"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

@get
external uri: resource => string = "uri"

@get
external name: resource => string = "name"

@return(nullable)
@get
external title: resource => option<string> = "title"

@return(nullable)
@get
external description: resource => option<string> = "description"

@return(nullable)
@get
external mimeType: resource => option<string> = "mimeType"

@return(nullable)
@get
external size: resource => option<float> = "size"

@return(nullable)
@get
external annotations: resource => option<McpAnnotations.t> = "annotations"

@return(nullable)
@get
external resourceMeta: resource => option<dict<unknown>> = "_meta"

@return(nullable)
@get
external icons: resource => option<array<McpIcon.t>> = "icons"
