type t
type kind = [#text | #image | #audio]

let text: string => t
let image: (~data: string, ~mimeType: string) => t
let audio: (~data: string, ~mimeType: string) => t
let kind: t => kind
let textValue: t => option<string>
let data: t => option<string>
let mimeType: t => option<string>
