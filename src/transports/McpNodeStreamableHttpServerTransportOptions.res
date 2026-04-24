// src/transports/McpNodeStreamableHttpServerTransportOptions.res
// Concern: expose the installed node Streamable HTTP transport-options alias without inventing a second ReScript record.
// Source: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`.
// Boundary: this module is a pure alias because the installed SDK exports the node options as the same runtime object shape as the web-standard options.
// Why this shape: mirroring the upstream alias keeps the public package names recognizable while avoiding a fake duplicate options type.
// Coverage: tests/BindingObjectSurface_test.res, tests/PublicWrapperCoverage_test.res
type t = McpWebStandardStreamableHttpServerTransportOptions.t

let make = McpWebStandardStreamableHttpServerTransportOptions.make
