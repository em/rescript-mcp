// src/core/McpAuthInfo.res
// Concern: construct authenticated request context for transport handlers.
type t

@obj
external make: (
  ~token: string,
  ~clientId: string,
  ~scopes: array<string>,
  ~expiresAt: float=?,
  ~resource: Webapi.Url.t=?,
  ~extra: dict<unknown>=?,
) => t = ""
