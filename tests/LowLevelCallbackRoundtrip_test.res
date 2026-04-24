open Vitest

@get external notificationParams: unknown => dict<unknown> = "params"

@schema
type codeForm = {code: string}

let notificationStringField = (notification, fieldName) =>
  notification->notificationParams->Dict.get(fieldName)->Option.map(McpTestBindings.unknownToString)

describe("low-level client callback roundtrip", () => {
  testAsync("server sampling, elicitation, and roots requests roundtrip through raw client handlers", async t => {
    let expect = value => t->expect(value)
    let server = McpTestBindings.makeLowLevelServer("callback-server", "1.0.0")
    let serverCapabilities =
      Dict.fromArray([
        ("logging", Dict.fromArray([])->McpTestBindings.dictToUnknown),
        ("completions", Dict.fromArray([])->McpTestBindings.dictToUnknown),
        ("prompts", Dict.fromArray([])->McpTestBindings.dictToUnknown),
        ("resources", Dict.fromArray([])->McpTestBindings.dictToUnknown),
      ])
    server->McpLowLevelServer.registerCapabilities(serverCapabilities)
    server->McpLowLevelServer.setRequestHandlerRaw(
      #completionComplete,
      async (_request, _extra) =>
        Dict.fromArray([
          (
            "completion",
            Dict.fromArray([
              (
                "values",
                ["alpha", "beta"]->Array.map(McpTestBindings.stringToUnknown)->McpTestBindings.arrayToUnknown,
              ),
            ])
            ->McpTestBindings.dictToUnknown,
          ),
        ])
        ->McpTestBindings.dictToUnknown,
    )

    let client = McpTestBindings.makeClient("callback-client", "1.0.0")
    let clientCapabilities =
      Dict.fromArray([
        ("sampling", Dict.fromArray([])->McpTestBindings.dictToUnknown),
        (
          "elicitation",
          Dict.fromArray([("form", Dict.fromArray([])->McpTestBindings.dictToUnknown)])
          ->McpTestBindings.dictToUnknown,
        ),
        ("roots", Dict.fromArray([])->McpTestBindings.dictToUnknown),
      ])
    client->McpTestBindings.registerClientCapabilities(clientCapabilities)

    client->McpTestBindings.setClientRequestHandlerRaw(
      #samplingCreateMessage,
      async (_request, _ctx) =>
        McpCreateMessageResult.make(
          ~model="test-model",
          ~role=#assistant,
          ~content=McpSamplingContent.text("sampled text"),
          (),
        )
        ->McpTestBindings.toUnknown,
    )

    client->McpTestBindings.setClientRequestHandlerRaw(
      #elicitationCreate,
      async (_request, _ctx) =>
        McpElicitResult.make(
          ~action=#accept,
          ~content=Dict.fromArray([("code", "1234"->McpTestBindings.stringToUnknown)]),
          (),
        )
        ->McpTestBindings.toUnknown,
    )

    client->McpTestBindings.setClientRequestHandlerRaw(
      #rootsList,
      async (_request, _ctx) =>
        Dict.fromArray([
          (
            "roots",
            [Dict.fromArray([
               ("uri", "file:///workspace"->McpTestBindings.stringToUnknown),
               ("name", "workspace"->McpTestBindings.stringToUnknown),
             ])->McpTestBindings.dictToUnknown]
            ->McpTestBindings.arrayToUnknown,
          ),
        ])
        ->McpTestBindings.dictToUnknown,
    )
    let loggingNotifications = ref([])
    let updatedResources = ref([])
    client->McpClient.setNotificationHandlerRaw(
      #message,
      async notification => {
        loggingNotifications := [
          ...loggingNotifications.contents,
          `${notification->notificationStringField("level")->Option.getOr("missing-level")}:${notification->notificationStringField("data")->Option.getOr("missing-data")}`,
        ]
      },
    )
    client->McpClient.setNotificationHandlerRaw(
      #resourcesUpdated,
      async notification => {
        updatedResources := [
          ...updatedResources.contents,
          notification->notificationStringField("uri")->Option.getOr("missing-uri"),
        ]
      },
    )

    let pair = McpTestBindings.makeLoopbackTransportPair("callback-session")
    let serverTransport = pair->McpTestBindings.loopbackServerTransport
    let clientTransport = pair->McpTestBindings.loopbackClientTransport
    await McpTestBindings.connectLowLevelServer(server, serverTransport)
    await McpTestBindings.connectClientWithTimeout(client, clientTransport, 5000)
    await server->McpLowLevelServer.sendLoggingMessage(
      McpLoggingMessageParams.make(~level=#info, ~data="callback-log"->McpTestBindings.stringToUnknown, ()),
    )
    await server->McpLowLevelServer.sendLoggingMessageWithSessionId(
      McpLoggingMessageParams.make(
        ~level=#notice,
        ~data="callback-log-session"->McpTestBindings.stringToUnknown,
        (),
      ),
      "callback-session",
    )
    await server->McpLowLevelServer.sendResourceUpdated(
      McpResourceUpdatedParams.make(~uri="memo://alpha", ()),
    )

    let pingResult = await server->McpLowLevelServer.ping
    let completionResult =
      await client->McpClient.complete(
        McpCompleteParams.makeWithPrompt(
          ~ref=McpCompleteParams.promptReference("review"),
          ~argument=McpCompleteParams.makeArgument(~name="topic", ~value="a", ()),
          (),
        ),
      )
    let samplingResult =
      await server->McpLowLevelServer.createMessage(
        McpCreateMessageParams.make(
          ~messages=[McpSamplingMessage.text(~role=#user, ~text="hello server")],
          ~maxTokens=64,
          (),
        ),
      )
    let elicitationResult =
      await server->McpLowLevelServer.elicitFormInput(
        McpElicitRequestFormParams.make(
          ~message="Provide a code",
          ~requestedSchema=codeFormSchema->McpStandardSchema.jsonSchemaOfRescriptSchema->McpTestBindings.toDict,
          (),
        ),
      )
    let rootsResult = await server->McpTestBindings.listRootsRaw

    (
      server->McpTestBindings.lowLevelServerCapabilities->Dict.get("logging") != None,
      server->McpLowLevelServer.getClientCapabilities != None,
      pingResult->McpEmptyResult.meta,
      completionResult->McpCompleteResult.completion->McpCompleteResult.values,
      samplingResult->McpCreateMessageResult.model,
      samplingResult->McpCreateMessageResult.role,
      samplingResult->McpCreateMessageResult.content->McpSamplingContent.textValue,
      elicitationResult->McpElicitResult.action,
      elicitationResult
      ->McpElicitResult.content
      ->Option.flatMap(content => content->Dict.get("code")->Option.map(McpTestBindings.unknownToString)),
      loggingNotifications.contents,
      updatedResources.contents,
      rootsResult
      ->McpListRootsResult.roots
      ->Array.map(root => (root->McpListRootsResult.uri, root->McpListRootsResult.name)),
    )
    ->expect
    ->Expect.toEqual((
      true,
      true,
      None,
      ["alpha", "beta"],
      "test-model",
      #assistant,
      Some("sampled text"),
      #accept,
      Some("1234"),
      ["info:callback-log", "notice:callback-log-session"],
      ["memo://alpha"],
      [("file:///workspace", Some("workspace"))],
    ))

    await TestSupport.settle([
      (async () => client->McpClient.removeNotificationHandlerRaw(#message))(),
      (async () => client->McpClient.removeNotificationHandlerRaw(#resourcesUpdated))(),
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      server->McpTestBindings.closeLowLevelServer->TestSupport.closeIgnore,
      serverTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
      clientTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })
})
