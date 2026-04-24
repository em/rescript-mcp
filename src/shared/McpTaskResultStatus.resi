type t = [#completed | #failed]

let toString: t => string
let fromString: string => t
