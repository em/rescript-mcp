// src/transports/McpStdioServerParameters.res
// Concern: construct the stdio client transport child-process parameters.
type t

@obj
external make: (
  ~command: string,
  ~args: array<string>=?,
  ~env: dict<string>=?,
  ~stderr: unknown=?,
  ~cwd: string=?,
) => t = ""
