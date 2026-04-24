type t

let make: (
  ~name: string,
  ~argumentValues: dict<string>=?,
  ~_meta: dict<unknown>=?,
  (),
) => t
let name: t => string
let argumentValues: t => option<dict<string>>
let meta: t => option<dict<unknown>>
