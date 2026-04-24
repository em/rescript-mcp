type config<'input, 'output>
type rawConfig<'input>
type registered
type updates<'input, 'output>
type rawUpdates<'input>
type updates0<'output>
type rawUpdates0

let makeConfig: (
  ~title: string=?,
  ~description: string=?,
  ~inputSchema: McpStandardSchema.t<'input>=?,
  ~outputSchema: McpStandardSchema.t<'output>,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  (),
) => config<'input, 'output>
let makeRawConfig: (
  ~title: string=?,
  ~description: string=?,
  ~inputSchema: McpStandardSchema.t<'input>=?,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  (),
) => rawConfig<'input>

let enable: registered => unit
let disable: registered => unit
let makeUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~paramsSchema: McpStandardSchema.t<'input>=?,
  ~outputSchema: McpStandardSchema.t<'output>,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.t<'output>>=?,
  ~enabled: bool=?,
  unit,
) => updates<'input, 'output>
let makeRawUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~paramsSchema: McpStandardSchema.t<'input>=?,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.raw>=?,
  ~enabled: bool=?,
  unit,
) => rawUpdates<'input>
let makeUpdates0: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~outputSchema: McpStandardSchema.t<'output>,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry (McpServerContext.t) => promise<McpCallToolResult.t<'output>>=?,
  ~enabled: bool=?,
  unit,
) => updates0<'output>
let makeRawUpdates0: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry (McpServerContext.t) => promise<McpCallToolResult.raw>=?,
  ~enabled: bool=?,
  unit,
) => rawUpdates0
let update: (registered, updates<'input, 'output>) => unit
let updateRaw: (registered, rawUpdates<'input>) => unit
let update0: (registered, updates0<'output>) => unit
let updateRaw0: (registered, rawUpdates0) => unit
let remove: registered => unit
