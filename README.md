# rescript-mcp

`rescript-mcp` is a reusable ReScript binding package for the public `@modelcontextprotocol/sdk`.

It is intentionally scoped to the public SDK's generic transport, client, server, and request-context surface. It does not ship application logic, OAuth discovery routes, Clerk helpers, or any statespace-specific MCP behavior.

Tested against:

- `@modelcontextprotocol/sdk@1.29.0`
- `rescript@12.2.0`

## Scope

This package binds the public entrypoints needed to build and consume MCP transports from ReScript:

- high-level `McpServer`
- low-level `Server`
- high-level `Client`
- web-standard Streamable HTTP server transport
- Node Streamable HTTP server transport
- stdio server and client transports
- Streamable HTTP client transport
- WebSocket client transport
- core implementation, auth, request-info, and transport/protocol option types

## Deliberate boundary

The public SDK's high-level registration API for tools, prompts, resources, and request handlers is coupled to `zod` and `AnySchema` values. `rescript-mcp` does not fake typed schema helpers with `dict<unknown>` or blanket `Obj.magic` wrappers.

The design boundary in this package is:

- bind the real schema-independent runtime surface directly
- expose the low-level server/client/transport lifecycle cleanly
- document the schema seam for a future companion package or explicit interop layer

The current design notes are in [docs/design.md](docs/design.md) and [docs/research.md](docs/research.md).

## Installation

```bash
npm install rescript-mcp @modelcontextprotocol/sdk
```

Add the package to your ReScript config:

```json
{
  "dependencies": ["rescript-mcp"]
}
```

## Module map

- Root export: `Mcp`
- Core: `McpImplementation`, `McpAuthInfo`, `McpRequestInfo`, `McpMessageExtraInfo`, `McpTypes`
- Shared: `McpTransport`, `McpTransportSendOptions`, `McpProtocolOptions`, `McpRequestOptions`
- Server: `McpServer`, `McpLowLevelServer`, `McpServerOptions`
- Client: `McpClient`, `McpClientOptions`
- Transports:
  - `McpWebStandardStreamableHttpServerTransport`
  - `McpNodeStreamableHttpServerTransport`
  - `McpStdioServerTransport`
  - `McpStdioClientTransport`
  - `McpStreamableHttpClientTransport`
  - `McpWebSocketClientTransport`

## Example

```rescript
let implementation = McpImplementation.make(~name="example-server", ~version="0.1.0")
let server = McpLowLevelServer.make(implementation)
let transport = McpWebStandardStreamableHttpServerTransport.make()

let _ = server->McpLowLevelServer.connect(transport)
```

## Verification

The repository uses Vitest for runtime verification:

- constructor and lifecycle coverage for server, client, and transports
- initialize and ping round-trip over stdio
- initialize and ping round-trip over HTTP client and server transports
- direct web-standard `Request` / `Response` verification for the web transport
- plain Node ESM import smoke coverage for the published entrypoints

Run:

```bash
npm install
npm test
```

## Release Management

- Versioning is managed with Changesets.
- Run `npm run changeset` when a user-facing change lands.
- The `release.yml` workflow opens or updates the release PR on `main`.
- Merging that release PR runs `npm run release` in GitHub Actions and publishes to npm.
- The repo needs a GitHub Actions secret named `NPM_TOKEN` with publish rights for `rescript-mcp`.
