type t
type action = [#cancel | #accept | #decline]

let make: (~action: action, ~content: dict<unknown>=?, ~_meta: dict<unknown>=?, ()) => t
let action: t => action
let content: t => option<dict<unknown>>
let meta: t => option<dict<unknown>>
