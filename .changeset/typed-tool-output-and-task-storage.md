---
"rescript-mcp": minor
---

Make the typed tool output path real and enforceable. Typed tool configs now require `outputSchema`, typed handlers return `McpCallToolResult.t<'output>`, the public client exposes `callTool` result classification, and typed tool-task results now flow through `McpTaskStore` and `McpRequestTaskStore`. Explicit raw secondary surfaces remain available through `McpCallToolResult.raw`, `registerToolRaw*`, `registerToolTaskRaw*`, `callToolRaw*`, and `*TaskResultRaw*`.
