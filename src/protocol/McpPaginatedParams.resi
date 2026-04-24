type t

let make: (~cursor: string=?, ~_meta: dict<unknown>=?, ()) => t
let cursor: t => option<string>
let meta: t => option<dict<unknown>>
