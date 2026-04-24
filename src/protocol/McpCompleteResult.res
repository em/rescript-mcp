// src/protocol/McpCompleteResult.res
// Concern: expose the installed `completion/complete` result object and its nested completion payload.
type t
type completion

@obj
external makeCompletion: (
  ~values: array<string>,
  ~total: float=?,
  ~hasMore: bool=?,
  (),
) => completion = ""

@obj
external make: (~completion: completion, ~_meta: dict<unknown>=?, ()) => t = ""

@get
external completion: t => completion = "completion"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

@get
external values: completion => array<string> = "values"

@return(nullable)
@get
external total: completion => option<float> = "total"

@return(nullable)
@get
external hasMore: completion => option<bool> = "hasMore"
