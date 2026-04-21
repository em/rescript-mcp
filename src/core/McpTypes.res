// src/core/McpTypes.res
// Concern: expose public SDK constants and opaque handles for broad protocol values.
type jsonRpcMessage
type requestId
type clientCapabilities
type serverCapabilities

@module("@modelcontextprotocol/sdk/types.js")
@val
external latestProtocolVersion: string = "LATEST_PROTOCOL_VERSION"

@module("@modelcontextprotocol/sdk/types.js")
@val
external defaultNegotiatedProtocolVersion: string = "DEFAULT_NEGOTIATED_PROTOCOL_VERSION"

@module("@modelcontextprotocol/sdk/types.js")
@val
external supportedProtocolVersions: array<string> = "SUPPORTED_PROTOCOL_VERSIONS"

@module("@modelcontextprotocol/sdk/types.js")
@val
external relatedTaskMetaKey: string = "RELATED_TASK_META_KEY"

@module("@modelcontextprotocol/sdk/types.js")
@val
external jsonRpcVersion: string = "JSONRPC_VERSION"

external jsonRpcMessageFromUnknown: unknown => jsonRpcMessage = "%identity"
external jsonRpcMessageToUnknown: jsonRpcMessage => unknown = "%identity"
external requestIdFromUnknown: unknown => requestId = "%identity"
external requestIdToUnknown: requestId => unknown = "%identity"
