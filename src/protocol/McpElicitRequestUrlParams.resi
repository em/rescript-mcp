type t

let make: (
  ~message: string,
  ~elicitationId: string,
  ~url: string,
  ~_meta: dict<unknown>=?,
  (),
) => t

let message: t => string
let elicitationId: t => string
let url: t => string
let meta: t => option<dict<unknown>>
