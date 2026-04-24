type t
type level = [#alert | #critical | #debug | #emergency | #error | #info | #notice | #warning]

let make: (~level: level, ~data: unknown, ~logger: string=?, ~_meta: dict<unknown>=?, unit) => t
let level: t => level
let data: t => unknown
let logger: t => option<string>
let meta: t => option<dict<unknown>>
