type t
type hint

let makeHint: (~name: string=?, ()) => hint
let make: (
  ~hints: array<hint>=?,
  ~costPriority: float=?,
  ~speedPriority: float=?,
  ~intelligencePriority: float=?,
  (),
) => t

let hints: t => option<array<hint>>
let costPriority: t => option<float>
let speedPriority: t => option<float>
let intelligencePriority: t => option<float>
let hintName: hint => option<string>
