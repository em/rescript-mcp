type t

let make: (
  ~authProvider: unknown=?,
  ~eventSourceInit: unknown=?,
  ~requestInit: Webapi.Fetch.requestInit=?,
  ~fetch: unknown=?,
  unit,
) => t
