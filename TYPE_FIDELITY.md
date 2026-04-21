# TYPE_FIDELITY

## Compromises made

### 1. Broad capabilities objects

- TS source: `ClientCapabilities`, `ServerCapabilities` in `dist/esm/types.d.ts`
- ReScript representation: `dict<unknown>` at the constructor boundary
- Why: the SDK exposes large open structural objects with nested optional branches; the package binds the realistic construction surface without inventing a fake closed record

### 2. Request and result payload objects

- TS source: client request params and result payloads in `dist/esm/client/index.d.ts`
- ReScript representation: `dict<unknown>` for request payloads and `promise<unknown>` for result payloads
- Why: the payload shapes vary by request method and many result types are wide nested unions; the package keeps the runtime shape honest and leaves method-specific decoding to consumers

### 3. Transport messages and request ids

- TS source: `JSONRPCMessage`, `RequestId` in `dist/esm/types.d.ts`
- ReScript representation: opaque handles in `McpTypes`, plus `unknown` in send-option and low-level call sites
- Why: the JSON-RPC message union is broad and mostly transported opaquely by consumers; binding it as a fake closed ReScript variant here would lie

### 4. Request handler schema boundary

- TS source: `Server.setRequestHandler` in `dist/esm/server/index.d.ts`
- ReScript representation: `setRequestHandlerRaw` with `unknown` schema and `unknown` request payload
- Why: the real API is parameterized by `AnyObjectSchema` and schema output; without a real `zod` interop layer, a typed helper would be fraudulent

### 5. Tool result schema boundary

- TS source: `Client.callTool(..., resultSchema)` in `dist/esm/client/index.d.ts`
- ReScript representation: `callToolWithResultSchemaRaw` with `unknown` result schema
- Why: the runtime surface genuinely accepts caller-owned schema values; the core package exposes the seam instead of inventing a fake typed schema API

### 6. High-level registration helpers omitted

- TS source: `registerTool`, `registerPrompt`, `registerResource` in `dist/esm/server/mcp.d.ts`
- ReScript representation: omitted from `rescript-mcp`
- Why: those helpers are coupled to `zod` and `AnySchema`; the correct design is a companion schema package or deliberate raw interop layer, not a false typed surface in the core package

### 7. Node request auth attachment

- TS source: `handleRequest(req: IncomingMessage & { auth?: AuthInfo }, ...)` in `dist/esm/server/streamableHttp.d.ts`
- ReScript representation: `handleRequest` and `handleRequestWithParsedBody` without a typed `req.auth` attachment helper
- Why: the auth field is a middleware mutation on a Node request object; the package exposes the transport directly and leaves middleware-specific request mutation to the host app
