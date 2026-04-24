type t

let make: (~uri: string, ~_meta: dict<unknown>=?, ()) => t
let uri: t => string
let meta: t => option<dict<unknown>>
