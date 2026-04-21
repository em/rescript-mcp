// src/transports/McpNodeStreamableHttpServerTransportOptions.res
// Concern: alias the node Streamable HTTP transport options to the web-standard transport options.
type t = McpWebStandardStreamableHttpServerTransportOptions.t

let make = McpWebStandardStreamableHttpServerTransportOptions.make
