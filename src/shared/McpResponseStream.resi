type t<'result>
type message<'result>
type kind = [#taskCreated | #taskStatus | #result | #error]

let toArray: t<'result> => promise<array<message<'result>>>
let takeResult: t<'result> => promise<'result>
let kind: message<'result> => kind
let task: message<'result> => option<McpTask.t>
let result: message<'result> => option<'result>
let error: message<'result> => option<unknown>
