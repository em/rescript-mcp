// src/protocol/McpListToolsResult.res
// Concern: expose the installed `tools/list` result object and tool descriptors.
type t
type tool
type annotations
type execution
type taskSupport = [#forbidden | #optional | #required]

@obj
external makeAnnotations: (
  ~title: string=?,
  ~readOnlyHint: bool=?,
  ~destructiveHint: bool=?,
  ~idempotentHint: bool=?,
  ~openWorldHint: bool=?,
  (),
) => annotations = ""

@obj
external makeExecution: (~taskSupport: taskSupport=?, ()) => execution = ""

@obj
external makeTool: (
  ~name: string,
  ~inputSchema: McpToolSchema.t,
  ~description: string=?,
  ~outputSchema: McpToolSchema.t=?,
  ~annotations: annotations=?,
  ~execution: execution=?,
  ~_meta: dict<unknown>=?,
  ~icons: array<McpIcon.t>=?,
  ~title: string=?,
  (),
) => tool = ""

@obj
external make: (~tools: array<tool>, ~nextCursor: string=?, ~_meta: dict<unknown>=?, ()) => t = ""

@get
external tools: t => array<tool> = "tools"

@return(nullable)
@get
external nextCursor: t => option<string> = "nextCursor"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

@get
external name: tool => string = "name"

@get
external inputSchema: tool => McpToolSchema.t = "inputSchema"

@return(nullable)
@get
external description: tool => option<string> = "description"

@return(nullable)
@get
external outputSchema: tool => option<McpToolSchema.t> = "outputSchema"

@return(nullable)
@get
external toolAnnotations: tool => option<annotations> = "annotations"

@return(nullable)
@get
external toolExecution: tool => option<execution> = "execution"

@return(nullable)
@get
external toolMeta: tool => option<dict<unknown>> = "_meta"

@return(nullable)
@get
external icons: tool => option<array<McpIcon.t>> = "icons"

@return(nullable)
@get
external title: tool => option<string> = "title"

@return(nullable)
@get
external annotationTitle: annotations => option<string> = "title"

@return(nullable)
@get
external readOnlyHint: annotations => option<bool> = "readOnlyHint"

@return(nullable)
@get
external destructiveHint: annotations => option<bool> = "destructiveHint"

@return(nullable)
@get
external idempotentHint: annotations => option<bool> = "idempotentHint"

@return(nullable)
@get
external openWorldHint: annotations => option<bool> = "openWorldHint"

@return(nullable)
@get
external taskSupport: execution => option<taskSupport> = "taskSupport"
