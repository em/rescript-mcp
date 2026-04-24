type t

let make: (~taskId: string, unit) => t
let taskId: t => string
