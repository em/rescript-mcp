# Experimental Task Surface Audit

## Scope

This audit covers the public task-management surface added on top of the installed `@modelcontextprotocol/{client,server}@2.0.0-alpha.2` line:

- `McpTaskStatus`, `McpTask`, `McpTaskCreationParams`, `McpCreateTaskOptions`, `McpRelatedTaskMetadata`, `McpTaskManagerOptions`, `McpTaskStore`, `McpRequestTaskStore`, `McpTaskContext`, and `McpResponseStream`
- protocol task result modules: `McpCreateTaskResult`, `McpGetTaskResult`, `McpListTasksResult`, and `McpCancelTaskResult`
- `McpServerContext.task`
- `McpClient.experimentalTasks`, `McpLowLevelServer.experimentalTasks`, and `McpServer.experimentalTasks`
- `McpTaskTool` and `McpServerExperimentalTasks.registerToolTask`
- typed `tasks`, `task`, and `relatedTask` fields on protocol, server, client, and request option builders

## Upstream Evidence

- `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`
  - `TaskCreationParams`, `CreateTaskOptions`, `RelatedTaskMetadata`, `Task`, `TaskContext`, `TaskManagerOptions`, `RequestTaskStore`
  - `ExperimentalServerTasks`, `ExperimentalMcpServerTasks`
  - `CreateTaskResult`, `GetTaskResult`, `ListTasksResult`, `CancelTaskResult`
- `node_modules/@modelcontextprotocol/client/dist/index.d.mts`
  - `ExperimentalClientTasks`

## Boundaries And Decisions

- Task status is a closed ReScript variant because the installed SDK exports a finite string union.
- Task records and task result records are bound as opaque runtime objects with explicit field accessors.
- `McpRequestTaskStore.storeTaskResult` and `getTaskResult` remain open at `unknown` because the SDK result type varies by request method.
- `McpTaskStore` and `McpTaskMessageQueue` now bind both the bundled in-memory implementations and public ReScript builders for custom structural implementations.
- Experimental request and stream methods with open protocol payloads are explicitly suffixed `Raw`.

## Runtime Proof

- `tests/ExperimentalTasksRoundtrip_test.res`
  - registers real task-based tools through `McpServer.experimentalTasks`
  - proves `McpServerContext.task` carries the request-scoped task store and requested TTL
  - proves `client.experimentalTasks.callToolStreamRawWithOptions`, `getTask`, `getTaskResultRawWithOptions`, `listTasksWithOptions`, and `cancelTaskWithOptions`
  - proves the typed request option task fields trigger the real task flow in the installed SDK
- `tests/BindingObjectSurface_test.res`
  - proves typed task option builders and task context field accessors exist on the public surface
- `tests/TaskStorageSurface_test.res`
  - proves the live `TaskStore` and `TaskMessageQueue` bindings, including custom store and queue construction
- `tests/ExperimentalServerTasksRoundtrip_test.res`
  - proves the low-level experimental task stream entrypoints against a live client/server loopback
- `docs/audits/task-runtime-storage-and-streams.md`
  - records the task runtime storage and low-level stream follow-up decisions and runtime probes

## Residual Risk

- high-level constructor task runtime still flows through the open `capabilities.tasks` dictionary boundary
- stored task results and queued task messages remain open where the upstream payload depends on the original request or JSON-RPC message union
