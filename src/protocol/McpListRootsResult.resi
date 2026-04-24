type t
type root

let makeRoot: (~uri: string, ~name: string=?, ~_meta: dict<unknown>=?, ()) => root
let make: (~roots: array<root>, ~_meta: dict<unknown>=?, ()) => t
let roots: t => array<root>
let meta: t => option<dict<unknown>>
let uri: root => string
let name: root => option<string>
let rootMeta: root => option<dict<unknown>>
