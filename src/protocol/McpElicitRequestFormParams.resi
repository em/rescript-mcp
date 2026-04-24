type t

let make: (~message: string, ~requestedSchema: dict<unknown>, ~_meta: dict<unknown>=?, ()) => t
let message: t => string
let requestedSchema: t => dict<unknown>
let meta: t => option<dict<unknown>>
