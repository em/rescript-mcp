---
"rescript-mcp": minor
---

Add typed ordinary sampling and elicitation wrappers on the public path.

This adds `McpCreateMessageParams`, `McpCreateMessageResult`, `McpModelPreferences`, `McpSamplingContent`, `McpSamplingMessage`, `McpElicitRequestFormParams`, `McpElicitRequestUrlParams`, and `McpElicitResult`, and wires `McpLowLevelServer` plus `McpServerContext` to use those typed request/result modules for the ordinary no-tools sampling path and the installed form/url elicitation path.
