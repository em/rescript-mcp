type t
type prompt
type promptArgument

let makePromptArgument: (~name: string, ~description: string=?, ~required: bool=?, ()) => promptArgument
let makePrompt: (
  ~name: string,
  ~title: string=?,
  ~description: string=?,
  ~argumentList: array<promptArgument>=?,
  ~_meta: dict<unknown>=?,
  ~icons: array<McpIcon.t>=?,
  (),
) => prompt
let make: (~prompts: array<prompt>, ~nextCursor: string=?, ~_meta: dict<unknown>=?, ()) => t
let prompts: t => array<prompt>
let nextCursor: t => option<string>
let meta: t => option<dict<unknown>>
let promptName: prompt => string
let promptTitle: prompt => option<string>
let promptDescription: prompt => option<string>
let promptArguments: prompt => option<array<promptArgument>>
let promptMeta: prompt => option<dict<unknown>>
let promptIcons: prompt => option<array<McpIcon.t>>
let argumentName: promptArgument => string
let argumentDescription: promptArgument => option<string>
let argumentRequired: promptArgument => option<bool>
