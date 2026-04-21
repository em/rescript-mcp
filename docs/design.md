# Design

## Goal

Publish a generic ReScript binding package for the public `@modelcontextprotocol/sdk` that can replace statespace's extracted binding seam without carrying any app behavior with it.

## Package shape

The library tree mirrors the real SDK concepts:

- `src/core`
  - implementation and request-context objects
  - public constants and coarse SDK type handles
- `src/shared`
  - transport and protocol options
  - transport send options
- `src/server`
  - low-level `Server`
  - high-level `McpServer`
  - server options
- `src/client`
  - high-level `Client`
  - client options
- `src/transports`
  - web-standard Streamable HTTP server transport
  - Node Streamable HTTP server transport
  - stdio server transport
  - stdio client transport
  - Streamable HTTP client transport
  - WebSocket client transport

## Naming

Module names stay close to the public SDK concepts and avoid statespace naming:

- `McpServer`
- `McpLowLevelServer`
- `McpClient`
- `McpWebStandardStreamableHttpServerTransport`
- `McpNodeStreamableHttpServerTransport`

## Type strategy

### Directly bound types

These are bound as concrete constructors or abstract handles:

- implementation objects
- auth info
- request info
- message extra info
- transport objects
- server and client objects

### Structural objects

Large open-ended SDK objects are kept structural:

- capabilities
- request params
- transport options with callback slots
- client request payloads and result payloads

Those values are represented with `dict<unknown>` or `unknown` at the ReScript boundary because the SDK itself models them as large structural objects and generic schema output.

### Zod-backed APIs

The high-level registration APIs are intentionally not faked.

The SDK types that cross a caller-owned schema boundary are:

- `McpServer.registerTool`
- `McpServer.registerPrompt`
- `McpServer.registerResource`
- `Server.setRequestHandler`
- `Client.callTool(..., resultSchema)`

The correct design is:

- keep `rescript-mcp` focused on lifecycle and transport correctness
- add a separate schema companion once the `zod` interop surface is designed deliberately
- use explicit raw interop only where the runtime SDK genuinely accepts caller-owned schema values

## Why not copy statespace's current binding shape unchanged

Statespace only needed:

- implementation
- auth info
- low-level server
- high-level server
- web-standard server transport

That is too narrow for an open-source package. The new package has to cover:

- client usage
- Node stdio workflows
- HTTP client transport
- request and protocol options
- migration documentation
- test coverage that proves the bindings work outside the app

## Verification design

The test suite is split by package boundary:

- `tests/core`
- `tests/server`
- `tests/client`
- `tests/transports`
- `tests/integration`

The integration suite covers:

- stdio initialize and ping
- HTTP client and server initialize and ping
- direct web-standard `Request` / `Response` handling

That verification is stronger than constructor-only smoke tests and proves that the bound runtime surface matches the real installed SDK.
