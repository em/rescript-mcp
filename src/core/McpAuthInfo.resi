type t

let make: (
  ~token: string,
  ~clientId: string,
  ~scopes: array<string>,
  ~expiresAt: float=?,
  ~resource: Webapi.Url.t=?,
  ~extra: dict<unknown>=?,
) => t
