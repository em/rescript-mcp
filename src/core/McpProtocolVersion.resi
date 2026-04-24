type t = [#v2024_10_07 | #v2024_11_05 | #v2025_03_26 | #v2025_06_18 | #v2025_11_25]

let toString: t => string
let fromString: string => t
let latest: t
let defaultNegotiated: t
let supported: array<t>
