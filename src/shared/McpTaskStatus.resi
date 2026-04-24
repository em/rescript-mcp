type t = [#working | #inputRequired | #completed | #failed | #cancelled]

let toString: t => string
let fromString: string => t
let isTerminal: t => bool
