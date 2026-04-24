// Concern: `UriTemplate.Variables` is `Record<string, string | string[]>` in the installed SDK.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: `value` stays `@unboxed` so `dict<value>` remains a plain JS record of strings or string arrays.
// Why this shape: the runtime preserves the scalar-or-array union without wrapper objects.
// Coverage: tests/BindingObjectSurface_test.res, tests/AuthoringLifecycleRoundtrip_test.res
type t
@unboxed
type value =
  | Single(string)
  | Multiple(array<string>)
type variables = dict<value>

@module("@modelcontextprotocol/server")
external isTemplate: string => bool = "UriTemplate.isTemplate"

@module("@modelcontextprotocol/server")
@new
external make: string => t = "UriTemplate"

@get
external variableNames: t => array<string> = "variableNames"

@send
external toString: t => string = "toString"

@send
external expand: (t, variables) => string = "expand"

@return(nullable)
@send external match: (t, string) => option<variables> = "match"

let matchRaw = match
