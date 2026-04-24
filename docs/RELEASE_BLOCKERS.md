# Release Blockers

This file is the active release gate for `rescript-mcp`.

If any blocker below is open:

- do not add new public surface
- do not broaden transport coverage
- do not treat docs rewrites or coverage growth as forward progress
- do not claim release readiness

The only work that counts is work that closes one of these blockers or produces the proof needed to close it.

## Blocker 1: Tool Output Typing Is Still Phantom

- status: CLOSED on 2026-04-23
- affected files:
  - `src/server/McpTool.resi`
  - `src/server/McpServer.resi`
  - `src/protocol/McpCallToolResult.resi`
  - `src/client/McpClient.res`
  - `src/client/McpClient.resi`
- closure:
  - `McpTool.makeConfig` and `McpTaskTool.makeConfig` now require `outputSchema` on the typed path.
  - `McpServer.registerTool*` and `McpServerExperimentalTasks.registerToolTask*` now require handlers that return `McpCallToolResult.t<'output>`.
  - `McpClient.callTool*` now exposes the matching public typed result-classification path.
  - raw and heterogeneous output paths are explicit secondary APIs: `registerToolRaw*`, `registerToolTaskRaw*`, and `callToolRaw*`.
- proof:
  - direct authoring and protocol tests in this repo must prove typed output success on the public binding surface
  - compile-shape checks inside this repo must reject declared output and actual output mismatches

## Blocker 2: Structured Content Is Still Open On The Typed 99% Path

- status: CLOSED on 2026-04-23
- affected files:
  - `src/protocol/McpCallToolResult.resi`
  - any package-authored construction modules added to construct typed tool results
- closure:
  - `McpCallToolResult.t<'output>` now carries ordinary typed ReScript structured content on the typed path.
  - `McpCallToolResult.raw` is the explicit secondary path for raw JSON-shaped structured content.
- proof:
  - direct repo tests must prove ordinary typed `structuredContent` on the public `McpCallToolResult.make` path

## Blocker 3: Task Runtime Still Forces Typed Results Through `unknown`

- status: CLOSED on 2026-04-23
- affected files:
  - `src/shared/McpTaskStore.resi`
  - `src/shared/McpRequestTaskStore.resi`
  - `src/shared/McpTaskMessageQueue.resi`
- closure:
  - `McpTaskStore.storeTaskResult*` and `McpRequestTaskStore.storeTaskResult*` now expose typed tool-result storage on the public 99% path.
  - `McpTaskStore.getTaskResult*` and `McpRequestTaskStore.getTaskResult*` now expose typed retrieval on the public 99% path.
  - raw heterogeneous task-result storage remains explicit through `storeTaskResultRaw*` and `getTaskResultRaw*`.
- proof:
  - direct repo tests must prove typed task-result storage and typed retrieval reuse on the public task-store APIs

## Blocker 4: Binding Tests Still Overstate Reality

- status: CLOSED on 2026-04-23
- affected files:
  - `docs/audits/external-consumer-proof-gap.md`
  - `docs/audits/periodic-external-consumer-review.md`
  - `docs/process/BINDING_PROOF_PROCESS.md`
  - `tests/support/McpTestBindings.res`
  - all tests that rely on package-local `*ToUnknown` or `%identity` support casts
- closure:
  - direct repo tests now cover all four blocker cases on the public binding surface.
  - typed-path claims no longer rely on package-local support casts.
  - remaining package-local `%identity` use in tests is now limited to raw low-level seams and raw protocol fixtures.
- proof:
  - direct repo tests and compile-shape checks cover the same typed paths without recreating consumer apps

## Release Rule

All four blocker rows are closed on 2026-04-23. Reopen the relevant row immediately if any of the proof cases regresses.
