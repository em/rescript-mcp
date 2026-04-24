type t

let make: McpImplementation.t => t
let makeWithOptions: (McpImplementation.t, McpServerOptions.t) => t
let experimentalTasks: t => McpServerExperimentalTasks.t
let server: t => McpLowLevelServer.t
let connect: (t, McpTransport.t) => promise<unit>
let close: t => promise<unit>
let registerTool: (
  t,
  string,
  McpTool.config<'input, 'output>,
  @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.t<'output>>,
) => McpTool.registered
let registerTool0: (
  t,
  string,
  McpTool.config<unit, 'output>,
  @uncurry (McpServerContext.t) => promise<McpCallToolResult.t<'output>>,
) => McpTool.registered
let registerToolRaw: (
  t,
  string,
  McpTool.rawConfig<'input>,
  @uncurry ('input, McpServerContext.t) => promise<McpCallToolResult.raw>,
) => McpTool.registered
let registerToolRaw0: (
  t,
  string,
  McpTool.rawConfig<unit>,
  @uncurry (McpServerContext.t) => promise<McpCallToolResult.raw>,
) => McpTool.registered
let registerPrompt: (
  t,
  string,
  McpPrompt.config<'args>,
  @uncurry ('args, McpServerContext.t) => promise<McpGetPromptResult.t>,
) => McpPrompt.registered
let registerPrompt0: (
  t,
  string,
  McpPrompt.config<unit>,
  @uncurry (McpServerContext.t) => promise<McpGetPromptResult.t>,
) => McpPrompt.registered
let registerResource: (
  t,
  string,
  string,
  McpResource.config,
  @uncurry (Webapi.Url.t, McpServerContext.t) => promise<McpReadResourceResult.t>,
) => McpResource.registered
let registerResourceTemplate: (
  t,
  string,
  McpResourceTemplate.t,
  McpResource.config,
  McpResourceTemplate.readCallback,
) => McpResourceTemplate.registered
let isConnected: t => bool
let sendLoggingMessage: (t, McpLoggingMessageParams.t) => promise<unit>
let sendLoggingMessageWithSessionId: (t, McpLoggingMessageParams.t, string) => promise<unit>
let sendResourceListChanged: t => unit
let sendToolListChanged: t => unit
let sendPromptListChanged: t => unit
