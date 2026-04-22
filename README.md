# rescript-mcp

ReScript bindings for the split Model Context Protocol TypeScript SDK packages:

- `@modelcontextprotocol/client`
- `@modelcontextprotocol/server`
- `@modelcontextprotocol/node`

The bindings stay close to the upstream SDK names and transport model, so the TypeScript MCP docs remain useful when working from ReScript.

## Install

```sh
npm install rescript-mcp @modelcontextprotocol/client @modelcontextprotocol/server @modelcontextprotocol/node
```

Add the package to `rescript.json`:

```json
{
  "dependencies": ["rescript-mcp"]
}
```

Supported package line:

- `@modelcontextprotocol/client@2.0.0-alpha.2`
- `@modelcontextprotocol/server@2.0.0-alpha.2`
- `@modelcontextprotocol/node@2.0.0-alpha.2`

## Quick Start

```rescript
let implementation = McpImplementation.make(~name="example-server", ~version="0.1.0")
let server = McpLowLevelServer.make(implementation)
let transport =
  McpWebStandardStreamableHttpServerTransport.makeWithOptions(
    McpWebStandardStreamableHttpServerTransportOptions.make(~enableJsonResponse=true, ()),
  )

let _promise = server->McpLowLevelServer.connect(transport)
```

## Package Guide

- `McpClient` covers client setup, connection, and request flow
- `McpLowLevelServer` and `McpServer` cover low-level server wiring and higher-level server helpers
- `McpTool`, `McpPrompt`, and `McpResource` cover server authoring helpers
- `McpProtocol` and related schema modules cover protocol objects and shared transport data
- transport modules cover stdio, Streamable HTTP, and web-standard server transports
- grouped re-exports also live under `Mcp`

Published package subpaths:

- `rescript-mcp`
- `rescript-mcp/auth`
- `rescript-mcp/protocol`
- `rescript-mcp/core`
- `rescript-mcp/shared`
- `rescript-mcp/server`
- `rescript-mcp/client`
- `rescript-mcp/transports`

Upstream package references:

- [`@modelcontextprotocol/client`](https://www.npmjs.com/package/@modelcontextprotocol/client)
- [`@modelcontextprotocol/server`](https://www.npmjs.com/package/@modelcontextprotocol/server)
- [`@modelcontextprotocol/node`](https://www.npmjs.com/package/@modelcontextprotocol/node)

Examples:

- [Basic server](https://github.com/em/rescript-mcp/blob/main/examples/BasicServer.res)
- [Basic client](https://github.com/em/rescript-mcp/blob/main/examples/BasicClient.res)

## Development

```sh
npm install
npm run build
npm test
```

## Release

Releases are versioned with Changesets and published by GitHub Actions through the repository workflow:

- [`.github/workflows/release.yml`](https://github.com/em/rescript-mcp/blob/main/.github/workflows/release.yml)
