# rescript-mcp

`rescript-mcp` is a reusable ReScript binding package for the public MCP TypeScript SDK packages:

- `@modelcontextprotocol/client`
- `@modelcontextprotocol/server`
- `@modelcontextprotocol/node`

Current package line:

- `@modelcontextprotocol/client@2.0.0-alpha.2`
- `@modelcontextprotocol/server@2.0.0-alpha.2`
- `@modelcontextprotocol/node@2.0.0-alpha.2`
- `rescript@12.2.0`

## Scope

This package binds the public entrypoints needed to build and consume MCP servers, clients, transports, and Standard Schema authoring from ReScript:

- high-level `McpServer`
- low-level `Server`
- high-level `Client`
- `McpStandardSchema` bridge from `rescript-schema`
- web-standard Streamable HTTP server transport
- Node Streamable HTTP server transport
- stdio server and client transports
- Streamable HTTP client transport
- core implementation, auth, request-info, and transport/protocol option types

## Maintenance Model

This package is maintained with Codex-assisted binding authorship.

Non-trivial public binding changes carry a written audit record, adversarial review, in-source rationale at important boundaries, and targeted soundness coverage. Material Codex-assisted commits are credited in git history with a Codex co-author trailer.

The maintainer workflow is documented in [`docs/process/BINDING_PROOF_PROCESS.md`](./docs/process/BINDING_PROOF_PROCESS.md).

## Installation

```bash
npm install rescript-mcp @modelcontextprotocol/client @modelcontextprotocol/server @modelcontextprotocol/node
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
- Server: `McpServer`, `McpLowLevelServer`, `McpServerOptions`, `McpTool`, `McpPrompt`, `McpResource`, `McpServerContext`
- Client: `McpClient`, `McpClientOptions`
- Transports:
  - `McpWebStandardStreamableHttpServerTransport`
  - `McpNodeStreamableHttpServerTransport`
  - `McpStdioServerTransport`
  - `McpStdioClientTransport`
  - `McpStreamableHttpClientTransport`

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
- authoring round-trip for tools, prompts, and resources
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
- Merging that release PR runs `npm run release:ci` in GitHub Actions and publishes to npm.
- Publishing is configured for npm trusted publishing from GitHub Actions, so there is no npm token to rotate once the package is linked on npm.
- Local shells do not publish this package. Do not run `npm publish` or `npm run release` locally.
