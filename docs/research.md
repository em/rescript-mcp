# Research

## Target versions

- target package: `@modelcontextprotocol/sdk@1.29.0`
- target ReScript compiler: `12.2.0`
- package role: reusable library bindings, not app-local FFI

## Usage model

Typical consumers of this package do six things:

1. Construct `Implementation` metadata for a client or server.
2. Create a low-level `Server` or high-level `McpServer`.
3. Create a `Client`.
4. Connect those endpoints over stdio or Streamable HTTP transports.
5. Handle web-standard `Request` and `Response` objects in framework route code.
6. Read negotiated capabilities, version data, session IDs, and request context metadata.

## Sources used

### Installed public SDK metadata

- package: `@modelcontextprotocol/sdk`
- version: `1.29.0`
- exports include:
  - `./client`
  - `./server`
  - `./shared/*`
  - `./validation/*`
  - `./experimental/*`

### Installed SDK declarations

Files used:

- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/server/index.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/server/mcp.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/server/webStandardStreamableHttp.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/server/streamableHttp.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/server/stdio.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/streamableHttp.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/websocket.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/shared/transport.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/shared/protocol.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/server/auth/types.d.ts`
- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/types.d.ts`

### Shipped README

File used:

- `/home/m/projects/rescript-mcp/node_modules/@modelcontextprotocol/sdk/README.md`

Relevant statements:

- the SDK is centered on `McpServer`, `Client`, stdio, and Streamable HTTP
- `zod` is a required peer dependency for the SDK's schema registration layer
- Streamable HTTP is the recommended remote transport

### Statespace migration reference

Files used:

- `/home/m/projects/statespace/src/bindings/mcp/Mcp_AuthInfo.res`
- `/home/m/projects/statespace/src/bindings/mcp/Mcp_Implementation.res`
- `/home/m/projects/statespace/src/bindings/mcp/Mcp_Server.res`
- `/home/m/projects/statespace/src/bindings/mcp/Mcp_McpServer.res`
- `/home/m/projects/statespace/src/bindings/mcp/Mcp_WebStandardStreamableHttpServerTransport.res`
- `/home/m/projects/statespace/app/routes/ApiMcpRoute.res`
- `/home/m/projects/statespace/app/screens/mcp/McpDiscovery.res`

## Resolved design facts

### 1. The package target is the stable SDK, not the split alpha packages

Reason:

- the user requirement narrowed the package to the public `@modelcontextprotocol/sdk`
- the installed stable package already exports the required client, server, and transport subpaths

### 2. Web-standard transport is the first-class server transport

Reason:

- the SDK ships `server/webStandardStreamableHttp`
- modern web frameworks already use Fetch `Request` and `Response`
- statespace's existing seed binding is already based on that surface

### 3. The Zod seam is real and cannot be papered over

Evidence:

- the README explicitly says the SDK has a required peer dependency on `zod`
- `server/mcp.d.ts` uses `AnySchema`, `AnyObjectSchema`, and `ZodRawShapeCompat`
- `server/index.d.ts` uses schema values in `setRequestHandler`
- `client/index.d.ts` uses optional result schemas in `callTool`

Decision:

- `rescript-mcp` binds the schema-independent transport and lifecycle surface directly
- `rescript-mcp` does not pretend that `registerTool`, `registerPrompt`, `registerResource`, or `setRequestHandler` can be typed correctly without a real schema interop strategy
- the correct extension point is a companion package or explicit raw interop seam around real `zod` values

### 4. Request-context types matter even without the registration helpers

Reason:

- `HandleRequestOptions.authInfo`
- `MessageExtraInfo`
- `RequestInfo`
- transport session and auth metadata

These types are needed by real apps that terminate auth before passing requests to the SDK.

### 5. Plain Node ESM cannot directly execute the SDK's wildcard subpath exports

Evidence:

- the package export pattern is `"./*": { "import": "./dist/esm/*" }`
- spawned plain Node processes do not resolve extensionless deep subpaths such as `@modelcontextprotocol/sdk/server/stdio`

Decision:

- the package bindings still target the public SDK subpaths because that is the declared API surface
- the Vitest stdio fixture uses a direct `.js` path for the spawned server process so runtime verification works under plain Node

## Package boundary

Included in `rescript-mcp`:

- constructors
- lifecycle methods
- transport request handlers
- request and protocol option objects
- implementation, auth, request-info, and message-extra-info objects
- client methods that do not require caller-supplied schemas

Left outside `rescript-mcp`:

- typed Zod schema authoring
- typed tool, prompt, and resource registration helpers
- app-level OAuth metadata routes
- Clerk integration
- product-specific tool/resource/prompt definitions
