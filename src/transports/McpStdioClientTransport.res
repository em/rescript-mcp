// src/transports/McpStdioClientTransport.res
// Concern: bind the stdio client transport.
type t = McpTransport.t

@module("@modelcontextprotocol/client")
@new
external make: McpStdioServerParameters.t => t = "StdioClientTransport"

@module("@modelcontextprotocol/client")
@val
external defaultInheritedEnvVars: array<string> = "DEFAULT_INHERITED_ENV_VARS"

@module("@modelcontextprotocol/client")
external getDefaultEnvironment: unit => dict<string> = "getDefaultEnvironment"

@return(nullable)
@get
external stderr: t => option<NodeJs.Stream.t> = "stderr"

@return(nullable)
@get
external pid: t => option<int> = "pid"
