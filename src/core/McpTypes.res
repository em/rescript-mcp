// src/core/McpTypes.res
// Concern: expose public SDK constants and opaque handles for broad protocol values.
type jsonRpcMessage
type requestId
type clientCapabilities
type serverCapabilities

@module("@modelcontextprotocol/server")
@val
external latestProtocolVersionRaw: string = "LATEST_PROTOCOL_VERSION"

@module("@modelcontextprotocol/server")
@val
external defaultNegotiatedProtocolVersionRaw: string = "DEFAULT_NEGOTIATED_PROTOCOL_VERSION"

@module("@modelcontextprotocol/server")
@val
external supportedProtocolVersionsRaw: array<string> = "SUPPORTED_PROTOCOL_VERSIONS"

let latestProtocolVersion = latestProtocolVersionRaw->McpProtocolVersion.fromString
let defaultNegotiatedProtocolVersion = defaultNegotiatedProtocolVersionRaw->McpProtocolVersion.fromString
let supportedProtocolVersions =
  supportedProtocolVersionsRaw->Array.map(McpProtocolVersion.fromString)

@module("@modelcontextprotocol/server")
@val
external relatedTaskMetaKey: string = "RELATED_TASK_META_KEY"

@module("@modelcontextprotocol/server")
@val
external jsonRpcVersion: string = "JSONRPC_VERSION"
