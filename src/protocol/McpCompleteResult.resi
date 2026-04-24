type t
type completion

let makeCompletion: (
  ~values: array<string>,
  ~total: float=?,
  ~hasMore: bool=?,
  (),
) => completion
let make: (~completion: completion, ~_meta: dict<unknown>=?, ()) => t
let completion: t => completion
let meta: t => option<dict<unknown>>
let values: completion => array<string>
let total: completion => option<float>
let hasMore: completion => option<bool>
