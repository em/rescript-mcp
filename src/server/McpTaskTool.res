// src/server/McpTaskTool.res
// Concern: construct task-tool configs and handlers for the high-level experimental task authoring API.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: typed task-tool handlers require `McpCallToolResult.t<'output>` plus `outputSchema`, while raw task-tool handlers stay explicit secondary APIs.
// Why this shape: the installed SDK preserves typed input through Standard Schema and returns tool-style results for task completion, so the binding keeps that typed contract end to end.
// Coverage: tests/ExperimentalTasksRoundtrip_test.res, tests/PublicWrapperCoverage_test.res, tests/CompileShape_test.res
type execution
type config<'input, 'output>
type rawConfig<'input>
type handler<'input, 'output>
type rawHandler<'input>
type handler0<'output>
type rawHandler0
type taskSupport = [#optional | #required]

@obj
external makeExecution: (~taskSupport: taskSupport=?, ()) => execution = ""

@obj
external makeConfig: (
  ~title: string=?,
  ~description: string=?,
  ~inputSchema: McpStandardSchema.t<'input>=?,
  ~outputSchema: McpStandardSchema.t<'output>,
  ~annotations: dict<unknown>=?,
  ~execution: execution=?,
  ~_meta: dict<unknown>=?,
  (),
) => config<'input, 'output> = ""

@obj
external makeRawConfig: (
  ~title: string=?,
  ~description: string=?,
  ~inputSchema: McpStandardSchema.t<'input>=?,
  ~annotations: dict<unknown>=?,
  ~execution: execution=?,
  ~_meta: dict<unknown>=?,
  (),
) => rawConfig<'input> = ""

@obj
external makeHandler: (
  ~createTask: @uncurry ('input, McpServerContext.t) => promise<McpCreateTaskResult.t>,
  ~getTask: @uncurry ('input, McpServerContext.t) => promise<McpGetTaskResult.t>,
  ~getTaskResult: @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.t<'output>>,
  (),
) => handler<'input, 'output> = ""

@obj
external makeRawHandler: (
  ~createTask: @uncurry ('input, McpServerContext.t) => promise<McpCreateTaskResult.t>,
  ~getTask: @uncurry ('input, McpServerContext.t) => promise<McpGetTaskResult.t>,
  ~getTaskResult: @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.raw>,
  (),
) => rawHandler<'input> = ""

@obj
external makeHandler0: (
  ~createTask: @uncurry (McpServerContext.t) => promise<McpCreateTaskResult.t>,
  ~getTask: @uncurry (McpServerContext.t) => promise<McpGetTaskResult.t>,
  ~getTaskResult: @uncurry (McpServerContext.t) => promise<McpCallToolResult.t<'output>>,
  (),
) => handler0<'output> = ""

@obj
external makeRawHandler0: (
  ~createTask: @uncurry (McpServerContext.t) => promise<McpCreateTaskResult.t>,
  ~getTask: @uncurry (McpServerContext.t) => promise<McpGetTaskResult.t>,
  ~getTaskResult: @uncurry (McpServerContext.t) => promise<McpCallToolResult.raw>,
  (),
) => rawHandler0 = ""
