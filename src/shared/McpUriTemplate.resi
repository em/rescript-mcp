type t
@unboxed
type value =
  | Single(string)
  | Multiple(array<string>)
type variables = dict<value>

let isTemplate: string => bool
let make: string => t
let variableNames: t => array<string>
let toString: t => string
let expand: (t, variables) => string
let match: (t, string) => option<variables>
let matchRaw: (t, string) => option<variables>
