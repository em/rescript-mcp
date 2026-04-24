# Task Runtime Storage And Streams Audit

## Scope

This audit covers the follow-up task-runtime binding pass on top of the installed `@modelcontextprotocol/{client,server}@2.0.0-alpha.2` line:

- `McpTaskResultStatus`
- `McpTaskStore.make`, `createTask*`, `storeTaskResult*`, `updateTaskStatus*`, and the `getTask` null-classification fix
- `McpTaskMessageQueue.make`, `enqueue`, `dequeue`, and `dequeueAll`
- low-level `McpLowLevelServerExperimentalTasks.requestStreamRaw`, `createMessageStreamRaw`, and `elicitInputStreamRaw` live proofs

## Upstream Evidence

- `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts`
  - `TaskStore.createTask`, `getTask`, `storeTaskResult`, `getTaskResult`, `updateTaskStatus`, and `listTasks`
  - `TaskMessageQueue.enqueue`, `dequeue`, and `dequeueAll`
  - `ExperimentalServerTasks.requestStream`, `createMessageStream`, and `elicitInputStream`
- `node_modules/@modelcontextprotocol/server/dist/index.mjs`
  - `InMemoryTaskStore.getTask()` returns `null` for a missing task
  - `InMemoryTaskMessageQueue.dequeue()` returns `undefined` for an empty queue
  - low-level experimental stream entrypoints delegate to task-manager request streaming

## Boundaries And Decisions

- `McpTaskResultStatus` is a closed variant because upstream only accepts `completed` and `failed` at the `storeTaskResult` boundary.
- `McpTaskStore.getTask` uses a JS shim so the public ReScript `option` reflects the real runtime `null` result instead of leaking a raw nullable value.
- `McpTaskStore.make` and `McpTaskMessageQueue.make` are package-authored builders that produce structural JS objects matching the installed interfaces.
- `McpTaskStore.createTask` keeps the original request payload open at `unknown` because the package still does not export the full method-indexed request union.
- `McpTaskMessageQueue` keeps queued messages open at `unknown` because the package still transports the JSON-RPC message union opaquely.
- low-level experimental stream entrypoints remain suffixed `Raw` because the final result payload depends on the request method.

## Runtime Proof

- `tests/TaskStorageSurface_test.res`
  - proves custom `TaskStore` and `TaskMessageQueue` builders dispatch through the live SDK method names
  - proves in-memory store writes, queue writes, and the `getTask` missing-task path normalize correctly at the public ReScript boundary
  - proves the narrowed `McpTaskResultStatus` input on both request-scoped and global store result writes
- `tests/ExperimentalServerTasksRoundtrip_test.res`
  - proves low-level `requestStreamRawWithOptions`, `createMessageStreamRawWithOptions`, and `elicitInputStreamRawWithOptions`
  - proves low-level `getTask`, `getTaskResultRawWithOptions`, `listTasksWithOptions`, and `cancelTaskWithOptions`
  - proves the client-side raw request handlers can create tasks through the bound request-scoped task store and complete them through the live SDK

## Residual Risk

- high-level constructor task runtime still flows through the open `capabilities.tasks` dictionary boundary
- task result payload mirrors, queued task messages, and original stored request payloads remain open because the package still does not export the full method-indexed request/result and JSON-RPC message unions
