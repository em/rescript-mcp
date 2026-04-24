type t
type promptReference
type resourceReference
type argument
type context

let promptReference: string => promptReference
let resourceReference: string => resourceReference
let makeArgument: (~name: string, ~value: string, ()) => argument
let makeContext: (~argumentValues: dict<string>=?, ()) => context
let makeWithPrompt: (
  ~ref: promptReference,
  ~argument: argument,
  ~context: context=?,
  ~_meta: dict<unknown>=?,
  (),
) => t
let makeWithResource: (
  ~ref: resourceReference,
  ~argument: argument,
  ~context: context=?,
  ~_meta: dict<unknown>=?,
  (),
) => t
let meta: t => option<dict<unknown>>
let argumentValue: t => argument
let contextValue: t => option<context>
let argumentName: argument => string
let argumentCurrentValue: argument => string
let contextArguments: context => option<dict<string>>
