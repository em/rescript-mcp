type t
type tool
type annotations
type execution
type taskSupport = [#forbidden | #optional | #required]

let makeAnnotations: (
  ~title: string=?,
  ~readOnlyHint: bool=?,
  ~destructiveHint: bool=?,
  ~idempotentHint: bool=?,
  ~openWorldHint: bool=?,
  (),
) => annotations
let makeExecution: (~taskSupport: taskSupport=?, ()) => execution
let makeTool: (
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
) => tool
let make: (~tools: array<tool>, ~nextCursor: string=?, ~_meta: dict<unknown>=?, ()) => t
let tools: t => array<tool>
let nextCursor: t => option<string>
let meta: t => option<dict<unknown>>
let name: tool => string
let inputSchema: tool => McpToolSchema.t
let description: tool => option<string>
let outputSchema: tool => option<McpToolSchema.t>
let toolAnnotations: tool => option<annotations>
let toolExecution: tool => option<execution>
let toolMeta: tool => option<dict<unknown>>
let icons: tool => option<array<McpIcon.t>>
let title: tool => option<string>
let annotationTitle: annotations => option<string>
let readOnlyHint: annotations => option<bool>
let destructiveHint: annotations => option<bool>
let idempotentHint: annotations => option<bool>
let openWorldHint: annotations => option<bool>
let taskSupport: execution => option<taskSupport>
