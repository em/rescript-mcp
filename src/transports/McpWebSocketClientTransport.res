// src/transports/McpWebSocketClientTransport.res
// Concern: bind the WebSocket client transport.
type t = McpTransport.t

@module("@modelcontextprotocol/sdk/client/websocket")
@new
external make: Webapi.Url.t => t = "WebSocketClientTransport"
