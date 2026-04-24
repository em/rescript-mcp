type t
type theme = [#dark | #light]

let make: (
  ~src: string,
  ~mimeType: string=?,
  ~sizes: array<string>=?,
  ~theme: theme=?,
  (),
) => t

let src: t => string
let mimeType: t => option<string>
let sizes: t => option<array<string>>
let theme: t => option<theme>
