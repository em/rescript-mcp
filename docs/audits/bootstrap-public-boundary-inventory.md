# Bootstrap Public Boundary Inventory Audit

## Claim

- subsystem: current public MCP binding surface
- change: record the actual current open boundaries and tie them to current tests so the next agent starts from observable facts instead of stale root notes
- boundary class: Standard Schema bridge, raw request/result seams, transport/protocol seams, metadata dictionaries
- exact public surface affected:
  - `src/protocol/McpStandardSchema.resi`
  - `src/server/McpServer.resi`
  - `src/server/McpLowLevelServer.resi`
  - `src/client/McpClient.resi`
  - `src/shared/McpTransport.resi`
  - `src/core/McpTypes.resi`

## Upstream Evidence

### Official Docs

- URL: not fetched in this bootstrap pass
- relevant excerpt or summary: the next code-changing agent must fetch official upstream docs for any changed area

### Declaration Evidence

- file: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`
- relevant signature:
  - line 9114: `interface Transport`
  - line 9128: `send(message: JSONRPCMessage, options?: TransportSendOptions): Promise<void>;`
  - line 9493: `setRequestHandler<M extends RequestMethod>(method: M, handler: (request: RequestTypeMap[M], ctx: ContextT) => Result | Promise<Result>): void;`
  - line 9626: declaration comments identify the Standard Schema type accepted by `registerTool` and `registerPrompt`

### Runtime Evidence

- command or probe:
  - `npm run build`
  - `npm test`
- result:
  - build passes
  - authoring, stdio, HTTP, web-standard, and entrypoint tests run, but the command remains red because of coverage thresholds

## Local Representation

- affected files:
  - `src/protocol/McpStandardSchema.resi`
  - `src/server/McpServer.resi`
  - `src/server/McpLowLevelServer.resi`
  - `src/client/McpClient.resi`
  - `src/shared/McpTransport.resi`
  - `src/core/McpTypes.resi`
- chosen ReScript shape:
  - high-level authoring is exposed with typed handler arguments and typed result constructors
  - low-level request handling remains one raw seam
  - broad client protocol methods remain open on request and result payloads
  - transport send remains open on raw message payloads
  - protocol message and request-id handles remain opaque

## Alternatives Considered

### Alternative 1

- representation: keep the old root audit story that authoring support is still missing
- why rejected: the current public `.resi` and authoring roundtrip test prove that story is stale

### Alternative 2

- representation: pretend the current package is already type-complete because authoring APIs exist
- why rejected: the client, transport, and low-level server seams still expose major public `unknown` boundaries

## Adversarial Questions

- question: is the Standard Schema boundary actually exercised
- evidence-based answer: yes. `tests/AuthoringRoundtrip_test.res` authors tool, prompt, and resource schemas through `McpStandardSchema.fromRescriptSchema` and uses them through the client bindings.

- question: does the current client API still under-deliver on typed results
- evidence-based answer: yes. Many `McpClient` methods still take `dict<unknown>` and return `promise<unknown>`. That is documented in `docs/TYPE_FIDELITY.md` and `docs/TYPE_SOUNDNESS_AUDIT.md`.

- question: is the low-level request-handler seam still too open
- evidence-based answer: yes. `McpLowLevelServer.setRequestHandlerRaw` keeps method, request, and result open. There is not yet a direct targeted test for narrowing that seam.

## Failure Modes Targeted

- failure mode: another agent assumes authoring support is absent and designs the wrong architecture
- how the current design prevents or exposes it: this audit anchors the current authoring surface to `McpServer.resi`, `McpStandardSchema.resi`, and the authoring roundtrip test
- test or probe covering it: `tests/AuthoringRoundtrip_test.res`

- failure mode: broad client raw methods are mistaken for typed protocol coverage
- how the current design prevents or exposes it: this audit and the fidelity docs mark the client request/result surface as intentionally open
- test or probe covering it: `tests/AuthoringRoundtrip_test.res`, `tests/StdioRoundtrip_test.res`, `tests/HttpRoundtrip_test.res`

- failure mode: transport and low-level server seams remain untracked
- how the current design prevents or exposes it: the soundness matrix now has explicit rows for those boundaries
- test or probe covering it: `tests/HttpRoundtrip_test.res`, `tests/WebStandardRequestResponse_test.res`, `tests/BindingSurface_test.res`

## Evidence

### Build

- command: `npm run build`
- result: passes

### Tests

- command: `npm test`
- result: passes

### Pack

- command: `npm pack --dry-run`
- result: passes

### Soundness Matrix Update

- affected row:
  - `Authoring / Standard Schema and high-level registration`
  - `Client / broad request and result payload surface`
  - `Low-level Server / raw request-handler seam`
  - `Transport / raw JSON-RPC send boundary`
  - `Web Transport / request/auth/parsed-body boundary`
  - `Node / HTTP / streamable HTTP server-client roundtrip`
- update made: linked those rows to this bootstrap boundary inventory

## Residual Risk

- remaining open boundary: client request/result typing, low-level request-handler typing, raw transport send, and metadata dictionaries
- why it remains open: these are implementation tasks for the next agent, not part of this process reset
- where it is documented: `docs/TYPE_FIDELITY.md`, `docs/TYPE_SOUNDNESS_AUDIT.md`, `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-22
