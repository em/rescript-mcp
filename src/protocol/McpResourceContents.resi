type t
type kind = [#text | #blob]

let text: (~uri: string, ~text: string, ~mimeType: string=?, ()) => t
let blob: (~uri: string, ~blob: string, ~mimeType: string=?, ()) => t
let kind: t => kind
let uri: t => string
let textValue: t => option<string>
let blobValue: t => option<string>
let mimeType: t => option<string>
