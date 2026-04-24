// src/shared/McpTaskResultStatus.res
// Concern: classify the finite final task-result statuses accepted by MCP task stores.
// Source: @modelcontextprotocol/{client,server} TaskStore.storeTaskResult and RequestTaskStore.storeTaskResult
// Boundary: closed string union input
// Why this shape: upstream only accepts `completed` and `failed` when storing a terminal task result.
// Coverage: tests/TaskStorageSurface_test.res and tests/ExperimentalTasksRoundtrip_test.res
type t = [#completed | #failed]

let toString = status =>
  switch status {
  | #completed => "completed"
  | #failed => "failed"
  }

let fromString = value =>
  switch value {
  | "completed" => #completed
  | "failed" => #failed
  | other => JsError.throwWithMessage("Unsupported MCP task result status: " ++ other)
  }
