type t = McpTransport.t

let make: McpStdioServerParameters.t => t
let defaultInheritedEnvVars: array<string>
let getDefaultEnvironment: unit => dict<string>
let stderr: t => option<NodeJs.Stream.t>
let pid: t => option<int>
