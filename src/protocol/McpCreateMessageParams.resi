type t
type includeContext = [#none | #thisServer | #allServers]

let make: (
  ~messages: array<McpSamplingMessage.t>,
  ~maxTokens: int,
  ~modelPreferences: McpModelPreferences.t=?,
  ~systemPrompt: string=?,
  ~includeContext: includeContext=?,
  ~temperature: float=?,
  ~stopSequences: array<string>=?,
  ~metadata: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  (),
) => t

let messages: t => array<McpSamplingMessage.t>
let maxTokens: t => int
let modelPreferences: t => option<McpModelPreferences.t>
let systemPrompt: t => option<string>
let includeContext: t => option<includeContext>
let temperature: t => option<float>
let stopSequences: t => option<array<string>>
let metadata: t => option<dict<unknown>>
let meta: t => option<dict<unknown>>
