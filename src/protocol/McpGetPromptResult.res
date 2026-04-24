// src/protocol/McpGetPromptResult.res
// Concern: construct `prompts/get` results returned by high-level prompt handlers.
type t

@obj
external make: (~messages: array<McpPromptMessage.t>, ~description: string=?, ()) => t = ""

@get
external messages: t => array<McpPromptMessage.t> = "messages"

@return(nullable)
@get
external description: t => option<string> = "description"
