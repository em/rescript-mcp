# rescript-mcp

ReScript bindings for the public MCP TypeScript SDK packages:

- `@modelcontextprotocol/client`
- `@modelcontextprotocol/server`
- `@modelcontextprotocol/node`

Supported package line:

- `@modelcontextprotocol/client@2.0.0-alpha.2`
- `@modelcontextprotocol/server@2.0.0-alpha.2`
- `@modelcontextprotocol/node@2.0.0-alpha.2`

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

## Example

```rescript
let implementation = McpImplementation.make(~name="example-server", ~version="0.1.0")
let server = McpLowLevelServer.make(implementation)
let transport =
  McpWebStandardStreamableHttpServerTransport.makeWithOptions(
    McpWebStandardStreamableHttpServerTransportOptions.make(~enableJsonResponse=true, ()),
  )

let _promise = server->McpLowLevelServer.connect(transport)
```

More examples:

- [Basic server](https://github.com/em/rescript-mcp/blob/main/examples/BasicServer.res)
- [Basic client](https://github.com/em/rescript-mcp/blob/main/examples/BasicClient.res)

## Package Layout

- `McpServer`, `McpLowLevelServer`, `McpTool`, `McpPrompt`, and `McpResource` cover server authoring
- `McpClient` covers MCP client setup and requests
- `McpStandardSchema` bridges MCP schemas to `rescript-schema`
- transport modules cover stdio, Streamable HTTP, and web-standard server handling
- root grouped modules live under [`src/Mcp.resi`](./src/Mcp.resi)

Published JS subpaths:

- `rescript-mcp`
- `rescript-mcp/auth`
- `rescript-mcp/protocol`
- `rescript-mcp/core`
- `rescript-mcp/shared`
- `rescript-mcp/server`
- `rescript-mcp/client`
- `rescript-mcp/transports`

## Development

```sh
npm install
npm run build
npm test
```

`npm test` runs the repository verification suite for bindings, protocol shapes, transports, authoring helpers, and package entrypoints.

## Releases

User-facing changes go through Changesets.

Publishing is owned by GitHub Actions in [`.github/workflows/release.yml`](./.github/workflows/release.yml). Local shells do not publish this package.

## Maintainer Docs

- [Type fidelity notes](https://github.com/em/rescript-mcp/blob/main/docs/TYPE_FIDELITY.md)
- [Binding proof process](https://github.com/em/rescript-mcp/blob/main/docs/process/BINDING_PROOF_PROCESS.md)
- [README contract](https://github.com/em/rescript-mcp/blob/main/docs/process/README_CONTRACT.md)

This repo uses Codex-assisted binding authorship. Material Codex-assisted changes are credited in git history, and non-trivial public binding changes carry written audits and review records.
