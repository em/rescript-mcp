type t

let registerToolTask: (
  t,
  string,
  McpTaskTool.config<'input, 'output>,
  McpTaskTool.handler<'input, 'output>,
) => McpTool.registered
let registerToolTask0: (
  t,
  string,
  McpTaskTool.config<unit, 'output>,
  McpTaskTool.handler0<'output>,
) => McpTool.registered
let registerToolTaskRaw: (
  t,
  string,
  McpTaskTool.rawConfig<'input>,
  McpTaskTool.rawHandler<'input>,
) => McpTool.registered
let registerToolTaskRaw0: (
  t,
  string,
  McpTaskTool.rawConfig<unit>,
  McpTaskTool.rawHandler0,
) => McpTool.registered
