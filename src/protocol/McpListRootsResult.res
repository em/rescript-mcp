// src/protocol/McpListRootsResult.res
// Concern: expose the installed `roots/list` result object and root descriptors.
type t
type root

@obj
external makeRoot: (~uri: string, ~name: string=?, ~_meta: dict<unknown>=?, ()) => root = ""

@obj
external make: (~roots: array<root>, ~_meta: dict<unknown>=?, ()) => t = ""

@get
external roots: t => array<root> = "roots"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

@get
external uri: root => string = "uri"

@return(nullable)
@get
external name: root => option<string> = "name"

@return(nullable)
@get
external rootMeta: root => option<dict<unknown>> = "_meta"
