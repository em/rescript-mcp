// src/protocol/McpListPromptsResult.res
// Concern: expose the installed `prompts/list` result object and prompt descriptors.
type t
type prompt
type promptArgument

@obj
external makePromptArgument: (~name: string, ~description: string=?, ~required: bool=?, ()) => promptArgument =
  ""

@obj
external makePrompt: (
  ~name: string,
  ~title: string=?,
  ~description: string=?,
  @as("arguments") ~argumentList: array<promptArgument>=?,
  ~_meta: dict<unknown>=?,
  ~icons: array<McpIcon.t>=?,
  (),
) => prompt = ""

@obj
external make: (~prompts: array<prompt>, ~nextCursor: string=?, ~_meta: dict<unknown>=?, ()) => t =
  ""

@get
external prompts: t => array<prompt> = "prompts"

@return(nullable)
@get
external nextCursor: t => option<string> = "nextCursor"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

@get
external promptName: prompt => string = "name"

@return(nullable)
@get
external promptTitle: prompt => option<string> = "title"

@return(nullable)
@get
external promptDescription: prompt => option<string> = "description"

@return(nullable)
@get
external promptArguments: prompt => option<array<promptArgument>> = "arguments"

@return(nullable)
@get
external promptMeta: prompt => option<dict<unknown>> = "_meta"

@return(nullable)
@get
external promptIcons: prompt => option<array<McpIcon.t>> = "icons"

@get
external argumentName: promptArgument => string = "name"

@return(nullable)
@get
external argumentDescription: promptArgument => option<string> = "description"

@return(nullable)
@get
external argumentRequired: promptArgument => option<bool> = "required"
