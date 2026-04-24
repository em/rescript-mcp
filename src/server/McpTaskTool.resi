type execution
type config<'input, 'output>
type rawConfig<'input>
type handler<'input, 'output>
type rawHandler<'input>
type handler0<'output>
type rawHandler0
type taskSupport = [#optional | #required]

let makeExecution: (~taskSupport: taskSupport=?, unit) => execution
let makeConfig: (
  ~title: string=?,
  ~description: string=?,
  ~inputSchema: McpStandardSchema.t<'input>=?,
  ~outputSchema: McpStandardSchema.t<'output>,
  ~annotations: dict<unknown>=?,
  ~execution: execution=?,
  ~_meta: dict<unknown>=?,
  unit,
) => config<'input, 'output>
let makeRawConfig: (
  ~title: string=?,
  ~description: string=?,
  ~inputSchema: McpStandardSchema.t<'input>=?,
  ~annotations: dict<unknown>=?,
  ~execution: execution=?,
  ~_meta: dict<unknown>=?,
  unit,
) => rawConfig<'input>
let makeHandler: (
  ~createTask: @uncurry ('input, McpServerContext.t) => promise<McpCreateTaskResult.t>,
  ~getTask: @uncurry ('input, McpServerContext.t) => promise<McpGetTaskResult.t>,
  ~getTaskResult: @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.t<'output>>,
  unit,
) => handler<'input, 'output>
let makeRawHandler: (
  ~createTask: @uncurry ('input, McpServerContext.t) => promise<McpCreateTaskResult.t>,
  ~getTask: @uncurry ('input, McpServerContext.t) => promise<McpGetTaskResult.t>,
  ~getTaskResult: @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.raw>,
  unit,
) => rawHandler<'input>
let makeHandler0: (
  ~createTask: @uncurry (McpServerContext.t) => promise<McpCreateTaskResult.t>,
  ~getTask: @uncurry (McpServerContext.t) => promise<McpGetTaskResult.t>,
  ~getTaskResult: @uncurry (McpServerContext.t) => promise<McpCallToolResult.t<'output>>,
  unit,
) => handler0<'output>
let makeRawHandler0: (
  ~createTask: @uncurry (McpServerContext.t) => promise<McpCreateTaskResult.t>,
  ~getTask: @uncurry (McpServerContext.t) => promise<McpGetTaskResult.t>,
  ~getTaskResult: @uncurry (McpServerContext.t) => promise<McpCallToolResult.raw>,
  unit,
) => rawHandler0
