// src/protocol/McpCompleteParams.res
// Concern: construct the installed `completion/complete` request params.
type t
type promptReference
type resourceReference
type argument
type context

@obj
external makePromptReferenceRaw: (@as("type") ~kind: string, ~name: string, ()) => promptReference =
  ""

let promptReference = name => makePromptReferenceRaw(~kind="ref/prompt", ~name, ())

@obj
external makeResourceReferenceRaw: (@as("type") ~kind: string, ~uri: string, ()) => resourceReference =
  ""

let resourceReference = uri => makeResourceReferenceRaw(~kind="ref/resource", ~uri, ())

@obj
external makeArgument: (~name: string, ~value: string, ()) => argument = ""

@obj
external makeContext: (@as("arguments") ~argumentValues: dict<string>=?, ()) => context = ""

@obj
external makeWithPrompt: (
  ~ref: promptReference,
  ~argument: argument,
  ~context: context=?,
  ~_meta: dict<unknown>=?,
  (),
) => t = ""

@obj
external makeWithResource: (
  ~ref: resourceReference,
  ~argument: argument,
  ~context: context=?,
  ~_meta: dict<unknown>=?,
  (),
) => t = ""

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"

@get
external argumentValue: t => argument = "argument"

@return(nullable)
@get
external contextValue: t => option<context> = "context"

@get
external argumentName: argument => string = "name"

@get
external argumentCurrentValue: argument => string = "value"

@return(nullable)
@get
external contextArguments: context => option<dict<string>> = "arguments"
