# Direct Binding Proof Audit

## Scope

This audit checks whether the typed public `rescript-mcp` path is proved directly inside this repository.

It covers the package-authored typed surfaces that claim more than thin raw interop:

- `McpStandardSchema.fromRescriptSchema`
- `McpServer.registerTool`
- `McpTool.config<'input, 'output>`
- `McpCallToolResult.make`
- `McpClient.callTool`
- `McpTaskStore.storeTaskResult` / `getTaskResult`
- `McpRequestTaskStore.storeTaskResult` / `getTaskResult`
- `Mcp.Shared.UriTemplate`

## Rejected Proof Models

- recreated consumer apps inside the binding repo
- tarball fixture scripts outside `npm test`
- typed-path claims that only compile because package-local `%identity` support casts stand in for real user code

## Direct Repo Proof

The repo-owned proof path is:

- `npm run build`
- `npm test`
- `npm pack --dry-run`

The typed public path is proved through these repo-owned tests:

- `tests/AuthoringRoundtrip_test.res`
  - typed tool registration and typed structured output through the public authoring surface
- `tests/AuthoringLifecycleRoundtrip_test.res`
  - registered-handle lifecycle, typed resource-template callbacks, and high-level server context behavior
- `tests/ClientProtocolRoundtrip_test.res`
  - typed `McpClient.callTool(..., schema)` result classification on the public client path
- `tests/ExperimentalTasksRoundtrip_test.res`
  - typed task-result storage and retrieval through the public task runtime
- `tests/ProtocolSurface_test.res`
  - typed public wrapper access for protocol-level modules
- `tests/CompileShape_test.res`
  - output-shape rejection runs from Vitest inside this repo and fails when the typed public contract drifts

## Support-Cast Inventory

Package-local `%identity` support casts remain in `tests/support/McpTestBindings.res`.

Those casts are acceptable only for intentionally raw seams such as:

- low-level request payload fabrication
- open metadata dictionaries
- raw protocol fixtures

They do not count as proof for the typed public path listed above.

## Residual Risk

The remaining open boundaries are still the raw ones documented elsewhere:

- low-level request and notification seams
- open metadata dictionaries
- queue payloads and stored original requests
- transport message payloads

Those stay explicit in:

- `docs/TYPE_FIDELITY.md`
- `docs/TYPE_SOUNDNESS_AUDIT.md`
- `docs/SOUNDNESS_MATRIX.md`

## Verdict

The typed public path is proved directly by repo-owned Vitest coverage inside `npm test`.

The binding no longer relies on recreated consumer harnesses for typed-path claims.
