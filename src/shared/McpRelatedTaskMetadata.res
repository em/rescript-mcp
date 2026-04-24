// src/shared/McpRelatedTaskMetadata.res
// Concern: construct related-task metadata for outbound MCP requests.
type t

@obj
external make: (~taskId: string, ()) => t = ""

@get
external taskId: t => string = "taskId"
