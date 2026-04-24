// src/protocol/McpElicitRequestUrlParams.res
// Concern: expose the URL-based elicitation request params.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts` `ElicitRequestURLParams`.
// Boundary: exact public protocol payload for the URL elicitation path.
// Why this shape: the installed SDK publishes a closed request object with stable string fields and no
// caller-owned nested schema leaf, so the binding can model the whole object directly.
// Coverage: tests/PublicWrapperCoverage_test.res
type t

@obj
external makeInternal: (
  @as("mode") ~mode_: string,
  ~message: string,
  ~elicitationId: string,
  ~url: string,
  ~_meta: dict<unknown>=?,
  (),
) => t = ""

let make = (~message, ~elicitationId, ~url, ~_meta=?, ()) =>
  makeInternal(~mode_="url", ~message, ~elicitationId, ~url, ~_meta?, ())

@get
external message: t => string = "message"

@get
external elicitationId: t => string = "elicitationId"

@get
external url: t => string = "url"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
