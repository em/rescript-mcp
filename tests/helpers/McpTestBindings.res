// tests/helpers/McpTestBindings.res
// Concern: export concrete helper functions so Vitest can exercise the ReScript bindings at runtime.

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

let makeRequestOptionsWithTimeout = timeout => McpRequestOptions.make(~timeout, ())

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

let makeStreamableHttpClientTransport = url =>
  McpStreamableHttpClientTransport.make(Webapi.Url.make(url))

let makeStreamableHttpClientTransportWithSession = (url, sessionId) =>
  McpStreamableHttpClientTransport.makeWithOptions(
    Webapi.Url.make(url),
    McpStreamableHttpClientTransportOptions.make(~sessionId, ()),
  )

let makeWebSocketClientTransport = url => McpWebSocketClientTransport.make(Webapi.Url.make(url))

let transportStart = transport => transport->McpTransport.start
let transportClose = transport => transport->McpTransport.close
let transportSessionId = transport => transport->McpTransport.sessionId

let connectLowLevelServer = (server, transport) => server->McpLowLevelServer.connect(transport)
let closeLowLevelServer = server => server->McpLowLevelServer.close
let pingLowLevelServer = server => server->McpLowLevelServer.ping

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
