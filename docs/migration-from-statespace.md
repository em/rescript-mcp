# Migration From Statespace

## Replacement map

### Current statespace binding files

| Statespace file | `rescript-mcp` replacement |
| --- | --- |
| `/home/m/projects/statespace/src/bindings/mcp/Mcp_Implementation.res` | `McpImplementation` |
| `/home/m/projects/statespace/src/bindings/mcp/Mcp_AuthInfo.res` | `McpAuthInfo` |
| `/home/m/projects/statespace/src/bindings/mcp/Mcp_Server.res` | `McpLowLevelServer` and `McpServerOptions` |
| `/home/m/projects/statespace/src/bindings/mcp/Mcp_McpServer.res` | `McpServer` |
| `/home/m/projects/statespace/src/bindings/mcp/Mcp_WebStandardStreamableHttpServerTransport.res` | `McpWebStandardStreamableHttpServerTransport`, `McpWebStandardStreamableHttpServerTransportOptions`, `McpWebStandardStreamableHttpHandleRequestOptions` |

## Dead code once statespace consumes `rescript-mcp`

These files become removable from statespace after imports are switched to the package:

- `/home/m/projects/statespace/src/bindings/mcp/Mcp_AuthInfo.res`
- `/home/m/projects/statespace/src/bindings/mcp/Mcp_Implementation.res`
- `/home/m/projects/statespace/src/bindings/mcp/Mcp_Server.res`
- `/home/m/projects/statespace/src/bindings/mcp/Mcp_McpServer.res`
- `/home/m/projects/statespace/src/bindings/mcp/Mcp_WebStandardStreamableHttpServerTransport.res`
- `/home/m/projects/statespace/tests/bindings/mcp/McpBindingSurface_test.mjs`

## Statespace code that remains app-specific

These files are not package material and should stay in statespace:

- `/home/m/projects/statespace/app/routes/ApiMcpRoute.res`
- `/home/m/projects/statespace/app/screens/mcp/McpDiscovery.res`

Reason:

- `ApiMcpRoute.res` is a product route boundary with app authentication behavior
- `McpDiscovery.res` is Clerk-specific OAuth and discovery response logic

Neither belongs in a generic MCP binding package.

## Practical migration steps

1. Add `rescript-mcp` to statespace dependencies.
2. Replace imports of the local `src/bindings/mcp/*` modules with the package modules.
3. Keep `ApiMcpRoute.res` and `McpDiscovery.res` in statespace.
4. Remove the old local binding files.
5. Remove the old local MCP binding test.

## Known boundary after migration

Statespace's discovery/auth/tool code stays in-repo.

`rescript-mcp` only replaces the generic SDK binding seam.
