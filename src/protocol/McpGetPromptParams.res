// src/protocol/McpGetPromptParams.res
// Concern: construct the installed `prompts/get` request params.
type t

@obj
external make: (
  ~name: string,
  @as("arguments") ~argumentValues: dict<string>=?,
  ~_meta: dict<unknown>=?,
  (),
) => t = ""

@get
external name: t => string = "name"

@return(nullable)
@get
external argumentValues: t => option<dict<string>> = "arguments"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
