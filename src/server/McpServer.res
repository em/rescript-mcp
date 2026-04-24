// src/server/McpServer.res
// Concern: bind the installed high-level `McpServer` class, including typed tool registration and authoring entrypoints.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: typed tool and task-tool handlers convert through `McpStandardSchema`, while raw registration APIs stay explicit secondary seams.
// Why this shape: the upstream high-level server mixes authoring APIs with dynamic raw seams, so the binding keeps typed registration honest without hiding the raw path.
// Coverage: tests/AuthoringLifecycleRoundtrip_test.res, tests/AuthoringRoundtrip_test.res, tests/PublicWrapperCoverage_test.res
type t
type experimental

@get
external toolConfigOutputSchema: McpTool.config<'input, 'output> => McpStandardSchema.t<'output> =
  "outputSchema"

@module("@modelcontextprotocol/server")
@new
external make: McpImplementation.t => t = "McpServer"

@module("@modelcontextprotocol/server")
@new
external makeWithOptions: (McpImplementation.t, McpServerOptions.t) => t = "McpServer"

@get
external experimentalRaw: t => experimental = "experimental"

@get
external experimentalTasksRaw: experimental => McpServerExperimentalTasks.t = "tasks"

let experimentalTasks = server => server->experimentalRaw->experimentalTasksRaw

@get
external server: t => McpLowLevelServer.t = "server"

@send
external connect: (t, McpTransport.t) => promise<unit> = "connect"

@send
external close: t => promise<unit> = "close"

@send
external registerToolUntyped: (
  t,
  string,
  McpTool.config<'input, 'output>,
  @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.raw>,
) => McpTool.registered = "registerTool"

@send
external registerToolRaw: (
  t,
  string,
  McpTool.rawConfig<'input>,
  @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.raw>,
) => McpTool.registered = "registerTool"

let registerTool = (server, name, config, callback) =>
  server->registerToolUntyped(
    name,
    config,
    async (args, ctx) => {
      let result = await callback(args, ctx)
      result->McpCallToolResultInternal.toRaw(config->toolConfigOutputSchema)
    },
  )

@send
external registerToolRaw0: (
  t,
  string,
  McpTool.rawConfig<unit>,
  @uncurry (McpServerContext.t) => promise<McpCallToolResult.raw>,
) => McpTool.registered = "registerTool"

@send
external registerTool0Untyped: (
  t,
  string,
  McpTool.config<unit, 'output>,
  @uncurry (McpServerContext.t) => promise<McpCallToolResult.raw>,
) => McpTool.registered = "registerTool"

let registerTool0 = (server, name, config, callback) =>
  server->registerTool0Untyped(
    name,
    config,
    async ctx => {
      let result = await callback(ctx)
      result->McpCallToolResultInternal.toRaw(config->toolConfigOutputSchema)
    },
  )

@send
external registerPrompt: (
  t,
  string,
  McpPrompt.config<'args>,
  @uncurry ('args, McpServerContext.t) => promise<McpGetPromptResult.t>,
) => McpPrompt.registered = "registerPrompt"

@send
external registerPrompt0: (
  t,
  string,
  McpPrompt.config<unit>,
  @uncurry (McpServerContext.t) => promise<McpGetPromptResult.t>,
) => McpPrompt.registered = "registerPrompt"

@send
external registerResource: (
  t,
  string,
  string,
  McpResource.config,
  @uncurry (Webapi.Url.t, McpServerContext.t) => promise<McpReadResourceResult.t>,
) => McpResource.registered = "registerResource"

@send
external registerResourceTemplate: (
  t,
  string,
  McpResourceTemplate.t,
  McpResource.config,
  McpResourceTemplate.readCallback,
) => McpResourceTemplate.registered = "registerResource"

@send
external isConnected: t => bool = "isConnected"

@send
external sendLoggingMessage: (t, McpLoggingMessageParams.t) => promise<unit> = "sendLoggingMessage"

@send
external sendLoggingMessageWithSessionId: (t, McpLoggingMessageParams.t, string) => promise<unit> =
  "sendLoggingMessage"

@send
external sendResourceListChanged: t => unit = "sendResourceListChanged"

@send
external sendToolListChanged: t => unit = "sendToolListChanged"

@send
external sendPromptListChanged: t => unit = "sendPromptListChanged"
