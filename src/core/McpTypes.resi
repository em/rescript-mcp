type jsonRpcMessage
type requestId
type clientCapabilities
type serverCapabilities

let latestProtocolVersion: string
let defaultNegotiatedProtocolVersion: string
let supportedProtocolVersions: array<string>
let relatedTaskMetaKey: string
let jsonRpcVersion: string
let jsonRpcMessageFromUnknown: unknown => jsonRpcMessage
let jsonRpcMessageToUnknown: jsonRpcMessage => unknown
let requestIdFromUnknown: unknown => requestId
let requestIdToUnknown: requestId => unknown
