// src/server/McpPrompt.res
// Concern: construct high-level prompt registration configs, update objects, and registered prompt lifecycle operations.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: prompt args stay schema-driven through `McpStandardSchema`, while prompt metadata remains an open dictionary boundary.
// Why this shape: the upstream high-level prompt API is a thin authoring layer with registered-object lifecycle methods, so the binding keeps that surface direct instead of wrapping it in package-owned abstractions.
// Coverage: tests/AuthoringLifecycleRoundtrip_test.res, tests/PublicWrapperCoverage_test.res
type config<'args>
type registered
type updates<'args>
type updates0

@obj
external makeConfig: (
  ~title: string=?,
  ~description: string=?,
  ~argsSchema: McpStandardSchema.t<'args>=?,
  ~_meta: dict<unknown>=?,
  (),
) => config<'args> = ""

@send
external enable: registered => unit = "enable"

@send
external disable: registered => unit = "disable"

@obj
external makeUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~argsSchema: McpStandardSchema.t<'args>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry ('args, McpServerContext.t) => promise<McpGetPromptResult.t>=?,
  ~enabled: bool=?,
  (),
) => updates<'args> = ""

@obj
external makeUpdates0: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry (McpServerContext.t) => promise<McpGetPromptResult.t>=?,
  ~enabled: bool=?,
  (),
) => updates0 = ""

@send
external update: (registered, updates<'args>) => unit = "update"

@send
external update0: (registered, updates0) => unit = "update"

@send
external remove: registered => unit = "remove"
