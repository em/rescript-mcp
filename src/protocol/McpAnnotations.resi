type t
type audience = [#assistant | #user]

let make: (
  ~audience: array<audience>=?,
  ~priority: float=?,
  ~lastModified: string=?,
  (),
) => t

let audience: t => option<array<audience>>
let priority: t => option<float>
let lastModified: t => option<string>
