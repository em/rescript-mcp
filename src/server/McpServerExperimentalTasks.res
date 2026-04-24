// src/server/McpServerExperimentalTasks.res
// Concern: bind the installed high-level experimental task registration surface on `McpServer.experimental.tasks`.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: typed task-tool results pass through `McpStandardSchema`, while raw task handlers remain explicit through `registerToolTaskRaw*`.
// Why this shape: the experimental task API reuses tool-result transport but splits create/get/result callbacks, so the binding needs one place that keeps the typed task-result path aligned.
// Coverage: tests/ExperimentalTasksRoundtrip_test.res, tests/PublicWrapperCoverage_test.res, tests/CompileShape_test.res
type t

@get
external taskToolOutputSchema: McpTaskTool.config<'input, 'output> => McpStandardSchema.t<'output> =
  "outputSchema"

@get
external createTaskHandler: McpTaskTool.handler<'input, 'output> => @uncurry (
  'input,
  McpServerContext.t,
) => promise<McpCreateTaskResult.t> = "createTask"

@get
external getTaskHandler: McpTaskTool.handler<'input, 'output> => @uncurry (
  'input,
  McpServerContext.t,
) => promise<McpGetTaskResult.t> = "getTask"

@get
external getTaskResultHandler: McpTaskTool.handler<'input, 'output> => @uncurry (
  'input,
  McpServerContext.t,
) => promise<McpCallToolResult.t<'output>> = "getTaskResult"

@get
external createTaskHandler0: McpTaskTool.handler0<'output> => @uncurry (
  McpServerContext.t,
) => promise<McpCreateTaskResult.t> = "createTask"

@get
external getTaskHandler0: McpTaskTool.handler0<'output> => @uncurry (
  McpServerContext.t,
) => promise<McpGetTaskResult.t> = "getTask"

@get
external getTaskResultHandler0: McpTaskTool.handler0<'output> => @uncurry (
  McpServerContext.t,
) => promise<McpCallToolResult.t<'output>> = "getTaskResult"

@send
external registerToolTaskUntyped: (
  t,
  string,
  McpTaskTool.config<'input, 'output>,
  McpTaskTool.rawHandler<'input>,
) => McpTool.registered = "registerToolTask"

@send
external registerToolTaskRaw: (
  t,
  string,
  McpTaskTool.rawConfig<'input>,
  McpTaskTool.rawHandler<'input>,
) => McpTool.registered = "registerToolTask"

let registerToolTask = (tasks, name, config, handler) =>
  tasks->registerToolTaskUntyped(
    name,
    config,
    McpTaskTool.makeRawHandler(
      ~createTask=handler->createTaskHandler,
      ~getTask=handler->getTaskHandler,
      ~getTaskResult=async (args, ctx) => {
        let result = await (handler->getTaskResultHandler)(args, ctx)
        result->McpCallToolResultInternal.toRaw(config->taskToolOutputSchema)
      },
      (),
    ),
  )

@send
external registerToolTaskRaw0: (
  t,
  string,
  McpTaskTool.rawConfig<unit>,
  McpTaskTool.rawHandler0,
) => McpTool.registered = "registerToolTask"

@send
external registerToolTask0Untyped: (
  t,
  string,
  McpTaskTool.config<unit, 'output>,
  McpTaskTool.rawHandler0,
) => McpTool.registered = "registerToolTask"

let registerToolTask0 = (tasks, name, config, handler) =>
  tasks->registerToolTask0Untyped(
    name,
    config,
    McpTaskTool.makeRawHandler0(
      ~createTask=handler->createTaskHandler0,
      ~getTask=handler->getTaskHandler0,
      ~getTaskResult=async ctx => {
        let result = await (handler->getTaskResultHandler0)(ctx)
        result->McpCallToolResultInternal.toRaw(config->taskToolOutputSchema)
      },
      (),
    ),
  )
