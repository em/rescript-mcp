// src/protocol/McpCreateMessageParams.res
// Concern: expose the no-tools sampling request params on the typed public path.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts` `CreateMessageRequestParams`
// and `CreateMessageRequestParamsBase`.
// Boundary: typed public subset for ordinary sampling requests without task augmentation or tool declarations.
// Why this shape: the installed SDK overloads the no-tools and tool-enabled sampling paths. The binding
// keeps the ordinary no-tools path typed here and leaves task-augmented or tool-enabled requests on the
// explicit raw path until their wider unions are bound directly.
// Coverage: tests/LowLevelCallbackRoundtrip_test.res, tests/AuthoringLifecycleRoundtrip_test.res
type t
type includeContext = [#none | #thisServer | #allServers]

@obj
external makeInternal: (
  ~messages: array<McpSamplingMessage.t>,
  ~maxTokens: int,
  ~modelPreferences: McpModelPreferences.t=?,
  ~systemPrompt: string=?,
  ~includeContext: string=?,
  ~temperature: float=?,
  ~stopSequences: array<string>=?,
  ~metadata: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  (),
) => t = ""

@get
external messages: t => array<McpSamplingMessage.t> = "messages"

@get
external maxTokens: t => int = "maxTokens"

@return(nullable)
@get
external modelPreferences: t => option<McpModelPreferences.t> = "modelPreferences"

@return(nullable)
@get
external systemPrompt: t => option<string> = "systemPrompt"

@return(nullable)
@get
external includeContextRaw: t => option<string> = "includeContext"

let includeContext = params =>
  switch includeContextRaw(params) {
  | Some("none") => Some(#none)
  | Some("thisServer") => Some(#thisServer)
  | Some("allServers") => Some(#allServers)
  | Some(value) => JsError.throwWithMessage("Unsupported MCP includeContext value: " ++ value)
  | None => None
  }

@return(nullable)
@get
external temperature: t => option<float> = "temperature"

@return(nullable)
@get
external stopSequences: t => option<array<string>> = "stopSequences"

@return(nullable)
@get
external metadata: t => option<dict<unknown>> = "metadata"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

let make = (
  ~messages,
  ~maxTokens,
  ~modelPreferences=?,
  ~systemPrompt=?,
  ~includeContext=?,
  ~temperature=?,
  ~stopSequences=?,
  ~metadata=?,
  ~_meta=?,
  (),
) => {
  let includeContext = switch includeContext {
  | Some(#none) => Some("none")
  | Some(#thisServer) => Some("thisServer")
  | Some(#allServers) => Some("allServers")
  | None => None
  }
  makeInternal(
    ~messages,
    ~maxTokens,
    ~modelPreferences?,
    ~systemPrompt?,
    ~includeContext?,
    ~temperature?,
    ~stopSequences?,
    ~metadata?,
    ~_meta?,
    (),
  )
}
