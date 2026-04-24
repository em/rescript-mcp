type t

let make: (~uri: string, ~_meta: dict<unknown>=?, unit) => t
let uri: t => string
let meta: t => option<dict<unknown>>
