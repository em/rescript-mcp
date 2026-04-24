// src/server/McpResource.res
// Concern: construct high-level static resource registration configs, update objects, and registered resource lifecycle operations.
type config
type registered
type updates

@obj
external makeConfig: (
  ~title: string=?,
  ~description: string=?,
  ~mimeType: string=?,
  ~size: float=?,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  (),
) => config = ""

@send
external enable: registered => unit = "enable"

@send
external disable: registered => unit = "disable"

@obj
external makeUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~uri: string=?,
  ~metadata: config=?,
  ~callback: @uncurry (Webapi.Url.t, McpServerContext.t) => promise<McpReadResourceResult.t>=?,
  ~enabled: bool=?,
  (),
) => updates = ""

@send
external update: (registered, updates) => unit = "update"

@send
external remove: registered => unit = "remove"
