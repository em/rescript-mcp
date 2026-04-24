// src/server/McpResourceTemplate.res
// Concern: bind the public ResourceTemplate authoring surface and registered handles.
type t
type callbacks
type completionContext
type registered
type updates

@send
external completionArgumentsRaw: completionContext => option<dict<string>> = "arguments"

let completionArguments = completionArgumentsRaw

type listCallback = @uncurry McpServerContext.t => promise<McpListResourcesResult.t>
type completeCallback = @uncurry (string, option<completionContext>) => promise<array<string>>
type readCallback = @uncurry (Webapi.Url.t, McpUriTemplate.variables, McpServerContext.t) => promise<
  McpReadResourceResult.t,
>

@obj
external makeCallbacks: (~list: option<listCallback>, ~complete: dict<completeCallback>=?, ()) => callbacks =
  ""

@module("@modelcontextprotocol/server")
@new
external make: (string, callbacks) => t = "ResourceTemplate"

@module("@modelcontextprotocol/server")
@new
external makeWithUriTemplate: (McpUriTemplate.t, callbacks) => t = "ResourceTemplate"

@get
external uriTemplate: t => McpUriTemplate.t = "uriTemplate"

@return(nullable)
@get
external listCallback: t => option<listCallback> = "listCallback"

@return(nullable)
@send
external completeCallback: (t, string) => option<completeCallback> = "completeCallback"

@obj
external makeUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~template: t=?,
  ~metadata: McpResource.config=?,
  ~callback: readCallback=?,
  ~enabled: bool=?,
  (),
) => updates = ""

@send
external enable: registered => unit = "enable"

@send
external disable: registered => unit = "disable"

@send
external update: (registered, updates) => unit = "update"

@send
external remove: registered => unit = "remove"
