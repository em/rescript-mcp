# Authoring Surface Alignment Audit

## Claim

- subsystem: stable authoring, transport, and grouped-entrypoint binding surface
- change: align the public ReScript API with the installed `2.0.0-alpha.2` MCP SDK line for resource templates, SSE transport, registered update handles, grouped module aliases, and server-context request APIs
- boundary class: authoring handle fidelity, dynamic request seams, grouped namespace type identity
- exact public surface affected:
  - `src/server/McpServer.resi`
  - `src/server/McpTool.resi`
  - `src/server/McpPrompt.resi`
  - `src/server/McpResource.resi`
  - `src/server/McpResourceTemplate.resi`
  - `src/server/McpServerContext.resi`
  - `src/shared/McpUriTemplate.resi`
  - `src/transports/McpSSEClientTransport.resi`
  - grouped `.resi` files under `src/`

## Upstream Evidence

### Declaration Evidence

- file: `node_modules/@modelcontextprotocol/server/dist/index.d.mts`
- relevant signatures:
  - `McpServer.registerResource(name, uriOrTemplate, config, readCallback)`
  - `ResourceTemplate`
  - `RegisteredTool.update(...)`
  - `RegisteredPrompt.update(...)`
  - `RegisteredResource.update(...)`
  - `RegisteredResourceTemplate.update(...)`
  - `ServerContext`

- file: `node_modules/@modelcontextprotocol/client/dist/index.d.mts`
- relevant signatures:
  - `Client.registerCapabilities(...)`
  - `Client.setRequestHandler(...)`
  - `SSEClientTransport`
  - `UriTemplate`

### Runtime Evidence

- command:
  - `npm run build`
  - `npm test`
  - `npm pack --dry-run`
- result:
  - all three pass on 2026-04-22

## Local Representation

- grouped `.resi` files now use module aliases so `Mcp.*` entrypoints preserve the same types as the underlying modules
- `McpResourceTemplate` binds the public constructor, callback accessors, registered handle, and update object
- `McpUriTemplate` binds the public constructor and open variable-map operations
- `McpServerContext` exposes the installed `mcpReq` request APIs and `http` accessors through explicit raw seams where the upstream payload types stay open
- `McpSSEClientTransport` is now present beside the existing Streamable HTTP and stdio bindings

## Alternatives Considered

### Alternative 1

- representation: keep grouped `.resi` files as `module type of ...`
- why rejected: that creates parallel abstract types at the root entrypoints and breaks interoperability across grouped modules

### Alternative 2

- representation: hide resource-template or server-context gaps behind handwritten JS wrappers
- why rejected: the installed runtime is already bindable directly, and the package should stay thin where the runtime contract is explicit

## Failure Modes Targeted

- failure mode: developers use `Mcp.Shared.UriTemplate` with `Mcp.Server.ResourceTemplate` and hit type inequality at compile time
- how the current design prevents or exposes it: grouped module aliases now preserve manifest type equality
- test or probe covering it: `tests/BindingObjectSurface_test.res`

- failure mode: registered `update` handles exist upstream but are silently unavailable from ReScript
- how the current design prevents or exposes it: each handle now has a public update object maker and update binding
- test or probe covering it: `tests/AuthoringLifecycleRoundtrip_test.res`

- failure mode: low-level server callback requests compile but hang or fail in tests because the transport path is wrong
- how the current design prevents or exposes it: the callback test now uses an in-process loopback transport instead of an HTTP path that suppresses initialization on session-bound transports
- test or probe covering it: `tests/LowLevelCallbackRoundtrip_test.res`

## Evidence

### Build

- command: `npm run build`
- result: passes

### Tests

- command: `npm test`
- result: passes with 11 files, 15 tests, 84.07% statements, 73.68% branches, 74.11% functions, and 83.95% lines

### Pack

- command: `npm pack --dry-run`
- result: passes

## Residual Risk

- remaining open boundary: broad `McpClient` request/result methods, `McpServerContext.sendRelatedNotificationRaw`, `McpResourceTemplate` variables, `McpUriTemplate.matchRaw`, and experimental task APIs
- why it remains open: those areas either remain intentionally open or are not yet bound in this pass
- where it is documented:
  - `docs/TYPE_FIDELITY.md`
  - `docs/TYPE_SOUNDNESS_AUDIT.md`
  - `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status: acceptable with documented open boundaries
- reviewer: Codex
- date: 2026-04-22
