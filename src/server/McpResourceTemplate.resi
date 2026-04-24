type t
type callbacks
type completionContext
type registered
type updates

type listCallback = @uncurry McpServerContext.t => promise<McpListResourcesResult.t>
type completeCallback = @uncurry (string, option<completionContext>) => promise<array<string>>
type readCallback = @uncurry (Webapi.Url.t, McpUriTemplate.variables, McpServerContext.t) => promise<
  McpReadResourceResult.t,
>

let completionArguments: completionContext => option<dict<string>>
let makeCallbacks: (~list: option<listCallback>, ~complete: dict<completeCallback>=?, unit) => callbacks
let make: (string, callbacks) => t
let makeWithUriTemplate: (McpUriTemplate.t, callbacks) => t
let uriTemplate: t => McpUriTemplate.t
let listCallback: t => option<listCallback>
let completeCallback: (t, string) => option<completeCallback>
let makeUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~template: t=?,
  ~metadata: McpResource.config=?,
  ~callback: readCallback=?,
  ~enabled: bool=?,
  unit,
) => updates
let enable: registered => unit
let disable: registered => unit
let update: (registered, updates) => unit
let remove: registered => unit
