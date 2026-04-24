# rescript-mcp

ReScript bindings for the split Model Context Protocol TypeScript SDK packages:

- `@modelcontextprotocol/client`
- `@modelcontextprotocol/server`
- `@modelcontextprotocol/node`

The bindings stay close to the upstream SDK names and transport model, so the TypeScript MCP docs remain useful when working from ReScript.

## Release Stage

This package is pre-alpha.

- current repo version line: `0.0.1-alpha.0`
- the repo release workflow is in PR-only mode
- stable `latest` publication requires explicit owner approval after the package leaves pre-alpha
- do not treat the current repo line as a stable production contract

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
- `McpLowLevelServer` and `McpServer` cover low-level server wiring and higher-level server APIs
- `McpTool`, `McpPrompt`, `McpResource`, and `McpResourceTemplate` cover server authoring APIs
- `Mcp.Server.ExperimentalTasks`, `Mcp.Client.ExperimentalTasks`, and `Mcp.Shared.Task*` cover the installed experimental task flow, pluggable task stores, and task queues
- `McpProtocol` and related schema modules cover typed protocol request/result objects, `Mcp.Protocol.JsonValue`, notification params, and shared transport data
- `Mcp.Shared.UriTemplate` exposes the upstream URI template surface used by resource templates
- transport modules cover stdio, Streamable HTTP, SSE, and web-standard server transports
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
npm pack --dry-run
```

## Release

Releases are versioned with Changesets.

The current repo stays in pre-alpha PR-only mode. GitHub Actions may open version PRs through the repository workflow, and stable npm publication remains gated behind explicit owner approval:

- [`.github/workflows/release.yml`](https://github.com/em/rescript-mcp/blob/main/.github/workflows/release.yml)

## Maintainer Docs

- [Type fidelity notes](https://github.com/em/rescript-mcp/blob/main/docs/TYPE_FIDELITY.md)
- [Type soundness audit](https://github.com/em/rescript-mcp/blob/main/docs/TYPE_SOUNDNESS_AUDIT.md)
- [Soundness matrix](https://github.com/em/rescript-mcp/blob/main/docs/SOUNDNESS_MATRIX.md)
- [Binding proof process](https://github.com/em/rescript-mcp/blob/main/docs/process/BINDING_PROOF_PROCESS.md)
- [README contract](https://github.com/em/rescript-mcp/blob/main/docs/process/README_CONTRACT.md)
