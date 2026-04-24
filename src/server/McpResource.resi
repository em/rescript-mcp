type config
type registered
type updates

let makeConfig: (
  ~title: string=?,
  ~description: string=?,
  ~mimeType: string=?,
  ~size: float=?,
  ~annotations: dict<unknown>=?,
  ~_meta: dict<unknown>=?,
  (),
) => config

let enable: registered => unit
let disable: registered => unit
let makeUpdates: (
  ~name: string=?,
  ~title: string=?,
  ~uri: string=?,
  ~metadata: config=?,
  ~callback: @uncurry (Webapi.Url.t, McpServerContext.t) => promise<McpReadResourceResult.t>=?,
  ~enabled: bool=?,
  unit,
) => updates
let update: (registered, updates) => unit
let remove: registered => unit
