// tests/support/McpTestBindings.res
// Concern: centralize test-only boundary casts and runtime fixture builders for the ReScript Vitest suite.
// Source: repo-owned Vitest fixtures plus `tests/support/LoopbackTransport.mjs`.
// Boundary: `%identity` casts stay isolated to test code so the public binding surface and individual specs do not duplicate raw interop.
// Why this shape: binding tests must construct and inspect `unknown` values at the JS boundary, but those casts are non-production and belong in one support module.
// Coverage: tests/BindingObjectSurface_test.res, tests/ClientProtocolRoundtrip_test.res, tests/PublicWrapperCoverage_test.res, tests/TaskStorageSurface_test.res
module Json = Mcp.Protocol.JsonValue

external toUnknown: 'a => unknown = "%identity"
external toDict: 'a => dict<unknown> = "%identity"
external unknownToString: unknown => string = "%identity"
external unknownToBool: unknown => bool = "%identity"
external unknownToInt: unknown => int = "%identity"
external unknownToFloat: unknown => float = "%identity"
external unknownToDict: unknown => dict<unknown> = "%identity"
external stringToUnknown: string => unknown = "%identity"
external boolToUnknown: bool => unknown = "%identity"
external floatToUnknown: float => unknown = "%identity"
external dictToUnknown: dict<unknown> => unknown = "%identity"
external arrayToUnknown: array<unknown> => unknown = "%identity"
external intToUnknown: int => unknown = "%identity"
external intToRequestId: int => McpTypes.requestId = "%identity"
external requestIdToInt: McpTypes.requestId => int = "%identity"
external jsonSchemaToDict: McpStandardSchema.jsonSchema => dict<JSON.t> = "%identity"
external jsonToUnknown: JSON.t => unknown = "%identity"
external rawCallToolResult: unknown => McpCallToolResult.raw = "%identity"
@get external callToolResultContentUnknown: unknown => array<McpContentBlock.t> = "content"
type loopbackTransportPair
@module("./LoopbackTransport.mjs")
external makeLoopbackTransportPair: string => loopbackTransportPair = "makeLoopbackTransportPair"
@get external loopbackServerTransport: loopbackTransportPair => McpTransport.t = "server"
@get external loopbackClientTransport: loopbackTransportPair => McpTransport.t = "client"

type toolDescriptor
type promptDescriptor
type resourceDescriptor
type resourceTemplateDescriptor
@get external createTaskResultTask: unknown => McpTask.t = "task"

let makeImplementation = (name, version) => McpImplementation.make(~name, ~version)

let makeLowLevelServer = (name, version) =>
  McpLowLevelServer.make(makeImplementation(name, version))

let makeLowLevelServerWithInstructions = (name, version, instructions) =>
  McpLowLevelServer.makeWithOptions(
    makeImplementation(name, version),
    McpServerOptions.make(~instructions, ()),
  )

let makeMcpServer = (name, version) => McpServer.make(makeImplementation(name, version))

let makeMcpServerWithInstructions = (name, version, instructions) =>
  McpServer.makeWithOptions(
    makeImplementation(name, version),
    McpServerOptions.make(~instructions, ()),
  )

let makeClient = (name, version) => McpClient.make(makeImplementation(name, version))

let makeClientWithOptions = (name, version) =>
  McpClient.makeWithOptions(makeImplementation(name, version), McpClientOptions.make(()))

let registerClientCapabilities = (client, capabilities) =>
  client->McpClient.registerCapabilities(capabilities)

let setClientRequestHandlerRaw = (client, method_, handler) =>
  client->McpClient.setRequestHandlerRaw(method_, handler)

let makeRequestOptionsWithTimeout = timeout => McpRequestOptions.make(~timeout, ())

let getSome = option =>
  switch option {
  | Some(value) => value
  | None => JsError.throwWithMessage("Expected value to be present")
  }

let makeTextContent = text =>
  Dict.fromArray([
    ("type", "text"->stringToUnknown),
    ("text", text->stringToUnknown),
  ])
  ->dictToUnknown

let makeSamplingRequestParams = (~text, ~maxTokens) =>
  Dict.fromArray([
    (
      "messages",
      [Dict.fromArray([
         ("role", "user"->stringToUnknown),
         ("content", makeTextContent(text)),
       ])->dictToUnknown]
      ->arrayToUnknown,
    ),
    ("maxTokens", maxTokens->intToUnknown),
  ])

let makeCodeElicitationRequestParams = message =>
  Dict.fromArray([
    ("mode", "form"->stringToUnknown),
    ("message", message->stringToUnknown),
    (
      "requestedSchema",
      Dict.fromArray([
        ("type", "object"->stringToUnknown),
        (
          "properties",
          Dict.fromArray([
            (
              "code",
              Dict.fromArray([("type", "string"->stringToUnknown)])
              ->dictToUnknown,
            ),
          ])
          ->dictToUnknown,
        ),
      ])
      ->dictToUnknown,
    ),
  ])

let makeWebStandardTransport = () => McpWebStandardStreamableHttpServerTransport.make()

let makeWebStandardJsonTransport = () =>
  McpWebStandardStreamableHttpServerTransport.makeWithOptions(
    McpWebStandardStreamableHttpServerTransportOptions.make(~enableJsonResponse=true, ()),
  )

let makeWebStandardStatefulJsonTransport = sessionId =>
  McpWebStandardStreamableHttpServerTransport.makeWithOptions(
    McpWebStandardStreamableHttpServerTransportOptions.make(
      ~sessionIdGenerator=(() => sessionId),
      ~enableJsonResponse=true,
      (),
    ),
  )

let makeNodeStreamableHttpTransport = () => McpNodeStreamableHttpServerTransport.make()

let makeNodeStreamableHttpJsonTransport = () =>
  McpNodeStreamableHttpServerTransport.makeWithOptions(
    McpNodeStreamableHttpServerTransportOptions.make(~enableJsonResponse=true, ()),
  )

let makeNodeStreamableHttpStatefulJsonTransport = sessionId =>
  McpNodeStreamableHttpServerTransport.makeWithOptions(
    McpNodeStreamableHttpServerTransportOptions.make(
      ~sessionIdGenerator=(() => sessionId),
      ~enableJsonResponse=true,
      (),
    ),
  )

let makeStdioServerTransport = () => McpStdioServerTransport.make()

let makeStdioClientTransport = (command, args, cwd) =>
  McpStdioClientTransport.make(McpStdioServerParameters.make(~command, ~args, ~cwd))

let makeSSEClientTransport = url =>
  McpSSEClientTransport.make(Webapi.Url.make(url))

let makeSSEClientTransportWithOptions = (url, options) =>
  McpSSEClientTransport.makeWithOptions(Webapi.Url.make(url), options)

let makeStreamableHttpClientTransport = url =>
  McpStreamableHttpClientTransport.make(Webapi.Url.make(url))

let makeStreamableHttpClientTransportWithSession = (url, sessionId) =>
  McpStreamableHttpClientTransport.makeWithOptions(
    Webapi.Url.make(url),
    McpStreamableHttpClientTransportOptions.make(~sessionId, ()),
  )

let transportStart = transport => transport->McpTransport.start
let transportClose = transport => transport->McpTransport.close
let transportSessionId = transport => transport->McpTransport.sessionId

let connectLowLevelServer = (server, transport) => server->McpLowLevelServer.connect(transport)
let closeLowLevelServer = server => server->McpLowLevelServer.close
let pingLowLevelServer = server => server->McpLowLevelServer.ping
let lowLevelServerCapabilities = server => server->McpLowLevelServer.getCapabilities
let createSamplingMessageRaw = (server, params) => server->McpLowLevelServer.createMessageRaw(params)
let elicitInputRaw = (server, params) => server->McpLowLevelServer.elicitInputRaw(params)
let listRootsRaw = server => server->McpLowLevelServer.listRoots

let connectMcpServer = (server, transport) => server->McpServer.connect(transport)
let closeMcpServer = server => server->McpServer.close
let mcpServerIsConnected = server => server->McpServer.isConnected

let connectClient = (client, transport) => client->McpClient.connect(transport)

let connectClientWithTimeout = (client, transport, timeout) =>
  client->McpClient.connectWithOptions(transport, makeRequestOptionsWithTimeout(timeout))

let closeClient = client => client->McpClient.close
let pingClient = client => client->McpClient.ping

let pingClientWithTimeout = (client, timeout) =>
  client->McpClient.pingWithOptions(makeRequestOptionsWithTimeout(timeout))

let clientServerCapabilities = client => client->McpClient.getServerCapabilities
let clientServerVersion = client => client->McpClient.getServerVersion
let clientNegotiatedProtocolVersion = client => client->McpClient.getNegotiatedProtocolVersion
let clientInstructions = client => client->McpClient.getInstructions

let httpClientTerminateSession = transport =>
  transport->McpStreamableHttpClientTransport.terminateSession

let httpClientProtocolVersion = transport =>
  transport->McpStreamableHttpClientTransport.protocolVersion

let nodeHandleRequest = (transport, req, res) =>
  transport->McpNodeStreamableHttpServerTransport.handleRequest(req, res)

let nodeHandleRequestWithParsedBody = (transport, req, res, parsedBody) =>
  transport->McpNodeStreamableHttpServerTransport.handleRequestWithParsedBody(req, res, parsedBody)

let webHandleRequest = (transport, request) =>
  transport->McpWebStandardStreamableHttpServerTransport.handleRequest(request)

let makeAuthInfo = (token, clientId, scopes) => McpAuthInfo.make(~token, ~clientId, ~scopes)

let webHandleRequestWithAuthInfo = (transport, request, authInfo) =>
  transport->McpWebStandardStreamableHttpServerTransport.handleRequestWithOptions(
    request,
    McpWebStandardStreamableHttpHandleRequestOptions.make(~authInfo, ()),
  )

let stdioClientPid = transport => transport->McpStdioClientTransport.pid
let stdioClientStderr = transport => transport->McpStdioClientTransport.stderr
let defaultInheritedEnvVars = McpStdioClientTransport.defaultInheritedEnvVars
let defaultEnvironment = () => McpStdioClientTransport.getDefaultEnvironment()

let listedTools = (result: McpListToolsResult.t) =>
  result->McpListToolsResult.tools->Array.map(item => (item->McpListToolsResult.name, item->McpListToolsResult.title))

let listedPrompts = (result: McpListPromptsResult.t) =>
  result
  ->McpListPromptsResult.prompts
  ->Array.map(item => (item->McpListPromptsResult.promptName, item->McpListPromptsResult.promptTitle))

let listedResources = (result: McpListResourcesResult.t) =>
  result
  ->McpListResourcesResult.resources
  ->Array.map(item => (item->McpListResourcesResult.uri, item->McpListResourcesResult.name))

let listedResourceTemplates = (result: McpListResourceTemplatesResult.t) =>
  result
  ->McpListResourceTemplatesResult.resourceTemplates
  ->Array.map(item => (
    item->McpListResourceTemplatesResult.uriTemplate,
    item->McpListResourceTemplatesResult.name,
  ))

let toolResultTexts = (result: McpCallToolResult.t<'output>) =>
  result->McpCallToolResult.content->Belt.Array.keepMap(McpContentBlock.textValue)

let toolResultTextsRaw = (result: McpCallToolResult.raw) =>
  result->McpCallToolResult.contentRaw->Belt.Array.keepMap(McpContentBlock.textValue)

let toolResultTextsUnknown = result =>
  result->callToolResultContentUnknown->Belt.Array.keepMap(McpContentBlock.textValue)

let toolResultStructuredField = (result: McpCallToolResult.raw, fieldName) =>
  result
  ->McpCallToolResult.structuredContentRaw
  ->Option.flatMap(dict =>
      dict->Dict.get(fieldName)->Option.flatMap(value =>
        switch value {
        | Json.String(text) => Some(text)
        | Json.Int(number) => Some(number->Int.toString)
        | Json.Float(number) => Some(number->Float.toString)
        | Json.Bool(flag) => Some(flag ? "true" : "false")
        | Json.Null => Some("null")
        | Json.Array(_) | Json.Object(_) => None
        }
      )
    )

let getPromptResultDescription = McpGetPromptResult.description

let promptResultTexts = (result: McpGetPromptResult.t) =>
  result
  ->McpGetPromptResult.messages
  ->Belt.Array.keepMap(message => message->McpPromptMessage.content->McpContentBlock.textValue)

let promptResultRoles = (result: McpGetPromptResult.t) =>
  result->McpGetPromptResult.messages->Array.map(McpPromptMessage.role)

let readResourceTexts = (result: McpReadResourceResult.t) =>
  result->McpReadResourceResult.contents->Belt.Array.keepMap(McpResourceContents.textValue)

let readResourceUris = (result: McpReadResourceResult.t) =>
  result->McpReadResourceResult.contents->Array.map(McpResourceContents.uri)
