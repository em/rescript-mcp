open Vitest

@get external responseJsonrpc: unknown => string = "jsonrpc"
@get external responseId: unknown => int = "id"
@get external responseResult: unknown => unknown = "result"
@get external initializeServerInfo: unknown => McpImplementation.t = "serverInfo"

let makeJsonRequest = (~protocolVersion: McpProtocolVersion.t, ~sessionId=?, body) => {
  let protocolVersion = protocolVersion->McpProtocolVersion.toString
  let headers = Dict.fromArray([
    ("accept", "application/json, text/event-stream"),
    ("content-type", "application/json"),
    ("mcp-protocol-version", protocolVersion),
  ])

  switch sessionId {
  | Some(sessionId) => headers->Dict.set("mcp-session-id", sessionId)
  | None => ()
  }

  Webapi.Fetch.Request.makeWithInit(
    "http://example.test/mcp",
    Webapi.Fetch.RequestInit.make(
      ~method_=Webapi.Fetch.Post,
      ~headers=headers->Webapi.Fetch.HeadersInit.makeWithDict,
      ~body=body->Webapi.Fetch.BodyInit.make,
      (),
    ),
  )
}

describe("web-standard streamable http transport", () => {
  testAsync("handles initialize and ping over Request and Response objects", async t => {
    let expect = value => t->expect(value)
    let server = McpTestBindings.makeLowLevelServerWithInstructions(
      "web-test-server",
      "1.0.0",
      "web test server",
    )
    let transport = McpTestBindings.makeWebStandardStatefulJsonTransport("web-test-session")
    let authInfo = McpTestBindings.makeAuthInfo("test-token", "test-client", ["read"])

    await McpTestBindings.connectLowLevelServer(server, transport)

    let initializeResponse = await McpTestBindings.webHandleRequestWithAuthInfo(
      transport,
      makeJsonRequest(
        ~protocolVersion=McpTypes.latestProtocolVersion,
        "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\""
        ++ (McpTypes.latestProtocolVersion->McpProtocolVersion.toString)
        ++ "\",\"capabilities\":{},\"clientInfo\":{\"name\":\"web-test-client\",\"version\":\"1.0.0\"}}}",
      ),
      authInfo,
    )
    let initializeBody = await initializeResponse->Webapi.Fetch.Response.json
    let initializeResult = initializeBody->McpTestBindings.jsonToUnknown->responseResult
    let negotiatedProtocolVersion =
      initializeResponse->Webapi.Fetch.Response.headers->Webapi.Fetch.Headers.get("mcp-protocol-version")
      ->Option.map(McpProtocolVersion.fromString)
      ->Option.getOr(McpTypes.latestProtocolVersion)
    let sessionId =
      initializeResponse->Webapi.Fetch.Response.headers->Webapi.Fetch.Headers.get("mcp-session-id")
      ->Option.getOr("")
    let pingResponse = await McpTestBindings.webHandleRequest(
      transport,
      makeJsonRequest(
        ~protocolVersion=negotiatedProtocolVersion,
        ~sessionId,
        "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"ping\",\"params\":{}}",
      ),
    )
    let pingBody = await pingResponse->Webapi.Fetch.Response.json

    (
      initializeResponse->Webapi.Fetch.Response.status,
      initializeResponse
      ->Webapi.Fetch.Response.headers
      ->Webapi.Fetch.Headers.get("content-type")
      ->Option.getOr("")
      ->String.includes("application/json"),
      initializeResult->initializeServerInfo,
      sessionId,
      pingResponse->Webapi.Fetch.Response.status,
      pingBody->McpTestBindings.jsonToUnknown->responseJsonrpc,
      pingBody->McpTestBindings.jsonToUnknown->responseId,
    )
    ->expect
    ->Expect.toEqual((
      200,
      true,
      McpTestBindings.makeImplementation("web-test-server", "1.0.0"),
      "web-test-session",
      200,
      "2.0",
      2,
    ))

    await TestSupport.settle([
      server->McpTestBindings.closeLowLevelServer->TestSupport.closeIgnore,
      transport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })
})
