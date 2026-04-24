---
"rescript-mcp": minor
---

Bind the installed URI-template variable union exactly. `Mcp.Shared.UriTemplate` now exposes `@unboxed` scalar-or-array variables through `Single(string)` and `Multiple(array<string>)`, `match` returns typed variables, and `Mcp.Server.ResourceTemplate.readCallback` now receives that typed variable map instead of `dict<unknown>`.
