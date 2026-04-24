type config<'args>
type registered
type updates<'args>
type updates0

let makeConfig: (
  ~title: string=?,
  ~description: string=?,
  ~argsSchema: McpStandardSchema.t<'args>=?,
  ~_meta: dict<unknown>=?,
  (),
) => config<'args>

let enable: registered => unit
let disable: registered => unit
let makeUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~argsSchema: McpStandardSchema.t<'args>=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry ('args, McpServerContext.t) => promise<McpGetPromptResult.t>=?,
  ~enabled: bool=?,
  unit,
) => updates<'args>
let makeUpdates0: (
  ~name: string=?,
  ~title: string=?,
  ~description: string=?,
  ~_meta: dict<unknown>=?,
  ~callback: @uncurry (McpServerContext.t) => promise<McpGetPromptResult.t>=?,
  ~enabled: bool=?,
  unit,
) => updates0
let update: (registered, updates<'args>) => unit
let update0: (registered, updates0) => unit
let remove: registered => unit
