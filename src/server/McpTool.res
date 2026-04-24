// src/server/McpTool.res
// Concern: construct high-level tool registration configs, update objects, and registered tool lifecycle operations.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: typed configs and updates require `outputSchema` and typed callback results, while raw configs and raw updates stay explicit.
// Why this shape: the high-level tool authoring API is schema-driven on the typed path and still exposes raw heterogeneous result seams, so the binding separates those contracts instead of widening everything.
// Coverage: tests/AuthoringLifecycleRoundtrip_test.res, tests/PublicWrapperCoverage_test.res, tests/CompileShape_test.res
type config<'input, 'output>
type rawConfig<'input>
type registered
type updates<'input, 'output>
type rawUpdates<'input>
type updates0<'output>
type rawUpdates0

@obj
external makeConfig: (
  ~title: string=?,
  ~description: string=?,
  ~inputSchema: McpStandardSchema.t<'input>=?,
  ~outputSchema: McpStandardSchema.t<'output>,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  (),
) => config<'input, 'output> = ""

@obj
external makeRawConfig: (
  ~title: string=?,
  ~description: string=?,
  ~inputSchema: McpStandardSchema.t<'input>=?,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  (),
) => rawConfig<'input> = ""

@send
external enable: registered => unit = "enable"

@send
external disable: registered => unit = "disable"

@obj
external makeUpdatesRaw: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~paramsSchema: McpStandardSchema.t<'input>=?,
  ~outputSchema: McpStandardSchema.t<'output>,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.raw>=?,
  ~enabled: bool=?,
  (),
) => updates<'input, 'output> = ""

let makeUpdates = (
  ~name=?,
  ~title=?,
  ~description=?,
  ~paramsSchema=?,
  ~outputSchema,
  ~annotations=?,
  ~_meta=?,
  ~callback=?,
  ~enabled=?,
  (),
) => {
  let callback =
    callback->Option.map(callback =>
      ((args, ctx) =>
        callback(args, ctx)->Promise.then(result => Promise.resolve(result->McpCallToolResultInternal.toRaw(outputSchema))))
    )
  makeUpdatesRaw(
    ~name?,
    ~title?,
    ~description?,
    ~paramsSchema?,
    ~outputSchema,
    ~annotations?,
    ~_meta?,
    ~callback?,
    ~enabled?,
    (),
  )
}

@obj
external makeRawUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~paramsSchema: McpStandardSchema.t<'input>=?,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.raw>=?,
  ~enabled: bool=?,
  (),
) => rawUpdates<'input> = ""

@obj
external makeUpdates0Raw: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~outputSchema: McpStandardSchema.t<'output>,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry (McpServerContext.t) => promise<McpCallToolResult.raw>=?,
  ~enabled: bool=?,
  (),
) => updates0<'output> = ""

let makeUpdates0 = (
  ~name=?,
  ~title=?,
  ~description=?,
  ~outputSchema,
  ~annotations=?,
  ~_meta=?,
  ~callback=?,
  ~enabled=?,
  (),
) => {
  let callback =
    callback->Option.map(callback =>
      (ctx =>
        callback(ctx)->Promise.then(result => Promise.resolve(result->McpCallToolResultInternal.toRaw(outputSchema))))
    )
  makeUpdates0Raw(
    ~name?,
    ~title?,
    ~description?,
    ~outputSchema,
    ~annotations?,
    ~_meta?,
    ~callback?,
    ~enabled?,
    (),
  )
}

@obj
external makeRawUpdates0: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry (McpServerContext.t) => promise<McpCallToolResult.raw>=?,
  ~enabled: bool=?,
  (),
) => rawUpdates0 = ""

@send
external update: (registered, updates<'input, 'output>) => unit = "update"

@send
external updateRaw: (registered, rawUpdates<'input>) => unit = "update"

@send
external update0: (registered, updates0<'output>) => unit = "update"

@send
external updateRaw0: (registered, rawUpdates0) => unit = "update"

@send
external remove: registered => unit = "remove"
