type rec t =
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | Array(array<t>)
  | Object(dict<t>)

let bool: bool => t
let int: int => t
let float: float => t
let string: string => t
let array: array<t> => t
let object: dict<t> => t
let toJSON: t => JSON.t
