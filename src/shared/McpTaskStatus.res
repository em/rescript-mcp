// src/shared/McpTaskStatus.res
// Concern: classify the finite task status strings exported by the MCP SDK.
type t = [#working | #inputRequired | #completed | #failed | #cancelled]

let toString = status =>
  switch status {
  | #working => "working"
  | #inputRequired => "input_required"
  | #completed => "completed"
  | #failed => "failed"
  | #cancelled => "cancelled"
  }

let fromString = value =>
  switch value {
  | "working" => #working
  | "input_required" => #inputRequired
  | "completed" => #completed
  | "failed" => #failed
  | "cancelled" => #cancelled
  | other => JsError.throwWithMessage("Unsupported MCP task status: " ++ other)
  }

@module("@modelcontextprotocol/server")
external isTerminalRaw: string => bool = "isTerminal"

let isTerminal = status => status->toString->isTerminalRaw
