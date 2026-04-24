open Vitest
module S = RescriptSchema.S
module Json = Mcp.Protocol.JsonValue

@schema
type echoArgs = {message: string}

@schema
type echoOutput = {
  sampled: string,
  code: string,
  root: string,
  httpRequestMissing: string,
}

@schema
type promptArgs = {topic: string}

@schema
type codeForm = {code: string}

type rootEntry

@get external notificationParams: unknown => dict<unknown> = "params"
@get external listedRoots: unknown => array<rootEntry> = "roots"
@get external rootUri: rootEntry => string = "uri"

let notificationStringField = (notification, fieldName) =>
  notification->notificationParams->Dict.get(fieldName)->Option.map(McpTestBindings.unknownToString)

let variableId = variables =>
  switch variables->Dict.get("id") {
  | Some(McpUriTemplate.Single(value)) => value
  | Some(McpUriTemplate.Multiple(values)) => values->Array.get(0)->Option.getOr("missing")
  | None => "missing"
  }

describe("authoring lifecycle roundtrip", () => {
  testAsync("high-level authoring handles register updates, resource templates, and server context request APIs", async t => {
    let expect = value => t->expect(value)
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
    let serverCapabilities =
      Dict.fromArray([("logging", Dict.fromArray([])->McpTestBindings.dictToUnknown)])
    let client = McpClient.makeWithOptions(
      McpTestBindings.makeImplementation("loopback-authoring-client", "1.0.0"),
      McpClientOptions.make(~capabilities=clientCapabilities, ()),
    )
    let server = McpServer.makeWithOptions(
      McpTestBindings.makeImplementation("loopback-authoring-server", "1.0.0"),
      McpServerOptions.make(~capabilities=serverCapabilities, ~instructions="loopback authoring server", ()),
    )
    let pair = McpTestBindings.makeLoopbackTransportPair("authoring-loopback")
    let serverTransport = pair->McpTestBindings.loopbackServerTransport
    let clientTransport = pair->McpTestBindings.loopbackClientTransport
    let timeoutOptions = McpRequestOptions.make(~timeout=5000, ())
    let loggingNotifications = ref([])

    let echoSchema = echoArgsSchema->McpStandardSchema.fromRescriptSchema
    let echoOutputStandardSchema = echoOutputSchema->McpStandardSchema.fromRescriptSchema
    let promptSchema = promptArgsSchema->McpStandardSchema.fromRescriptSchema

    client->McpTestBindings.setClientRequestHandlerRaw(
      #samplingCreateMessage,
      async (_request, _ctx) =>
        McpCreateMessageResult.make(
          ~model="sample-model",
          ~role=#assistant,
          ~content=McpSamplingContent.text("sampled-from-client"),
          (),
        )
        ->McpTestBindings.toUnknown,
    )
    client->McpTestBindings.setClientRequestHandlerRaw(
      #elicitationCreate,
      async (_request, _ctx) =>
        McpElicitResult.make(
          ~action=#accept,
          ~content=Dict.fromArray([("code", "42"->McpTestBindings.stringToUnknown)]),
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
            [Dict.fromArray([("uri", "file:///workspace"->McpTestBindings.stringToUnknown)])
             ->McpTestBindings.dictToUnknown]
            ->McpTestBindings.arrayToUnknown,
          ),
        ])
        ->McpTestBindings.dictToUnknown,
    )
    client->McpClient.setNotificationHandlerRaw(
      #message,
      async notification => {
        loggingNotifications := [
          ...loggingNotifications.contents,
          `${notification->notificationStringField("level")->Option.getOr("missing-level")}:${notification->notificationStringField("data")->Option.getOr("missing-data")}`,
        ]
      },
    )

    let toolHandle =
      server->McpServer.registerTool(
        "echo",
        McpTool.makeConfig(
          ~title="Echo",
          ~inputSchema=echoSchema,
          ~outputSchema=echoOutputStandardSchema,
          (),
        ),
        async (args, ctx) => {
          let sampling =
            await ctx->McpServerContext.requestSamplingWithOptions(
              McpCreateMessageParams.make(
                ~messages=[McpSamplingMessage.text(~role=#user, ~text="tool request")],
                ~maxTokens=32,
                (),
              ),
              timeoutOptions,
            )
          let elicitation =
            await ctx->McpServerContext.elicitFormInputWithOptions(
              McpElicitRequestFormParams.make(
                ~message="Provide a code",
                ~requestedSchema=codeFormSchema->McpStandardSchema.jsonSchemaOfRescriptSchema->McpTestBindings.toDict,
                (),
              ),
              timeoutOptions,
            )
          let roots =
            await ctx
            ->McpServerContext.sendRelatedRequestRawWithOptions(#rootsList, Dict.fromArray([]), timeoutOptions)
          let sampledText =
            sampling
            ->McpCreateMessageResult.content
            ->McpSamplingContent.textValue
            ->Option.getOr("missing")
          let code =
            elicitation
            ->McpElicitResult.content
            ->Option.flatMap(content => content->Dict.get("code")->Option.map(McpTestBindings.unknownToString))
            ->Option.getOr("missing")
          let root =
            roots->listedRoots->Array.map(root => root->rootUri)->Array.get(0)->Option.getOr("missing-root")
          await ctx->McpServerContext.sendRelatedNotificationRaw(
            #message,
            Dict.fromArray([
              ("level", "notice"->McpTestBindings.stringToUnknown),
              ("data", "tool-related"->McpTestBindings.stringToUnknown),
            ]),
          )
          await ctx->McpServerContext.log(#info, "tool invoked"->McpTestBindings.stringToUnknown)
          await ctx->McpServerContext.logWithLogger(
            #info,
            "tool invoked with logger"->McpTestBindings.stringToUnknown,
            "authoring-loopback",
          )
          McpCallToolResult.make(
            ~content=[
              McpContentBlock.text(
                `${args.message}|${sampledText}|${code}|${root}|${ctx->McpServerContext.requestMethod->McpMethod.requestToString}`,
              ),
            ],
            ~structuredContent={
              sampled: sampledText,
              code,
              root,
              httpRequestMissing: switch ctx->McpServerContext.httpRequest {
              | None => "true"
              | Some(_) => "false"
              },
            },
            (),
          )
        },
      )
    let pingHandle =
      server->McpServer.registerToolRaw0(
        "ping",
        McpTool.makeRawConfig(~title="Ping", ()),
        async _ctx =>
          McpCallToolResult.makeRaw(~content=[McpContentBlock.text("pong")], ()),
      )

    let promptHandle =
      server->McpServer.registerPrompt(
        "review",
        McpPrompt.makeConfig(~title="Review", ~argsSchema=promptSchema, ()),
        async (args, _ctx) =>
          McpGetPromptResult.make(
            ~messages=[McpPromptMessage.text(~role=#user, ~text="Review " ++ args.topic)],
            ~description="Review prompt",
            (),
          ),
      )
    let welcomeHandle =
      server->McpServer.registerPrompt0(
        "welcome",
        McpPrompt.makeConfig(~title="Welcome", ()),
        async _ctx =>
          McpGetPromptResult.make(
            ~messages=[McpPromptMessage.text(~role=#assistant, ~text="Welcome")],
            (),
          ),
      )

    let resourceHandle =
      server->McpServer.registerResource(
        "config",
        "config://app",
        McpResource.makeConfig(~title="Config", ~mimeType="application/json", ()),
        async (uri, _ctx) =>
          McpReadResourceResult.make([
            McpResourceContents.text(~uri=Webapi.Url.href(uri), ~text="{\"ok\":true}", ()),
          ]),
      )

    let resourceTemplate =
      McpResourceTemplate.make(
        "memo://{id}",
        McpResourceTemplate.makeCallbacks(
          ~list=None,
          ~complete=Dict.fromArray([
            (
              "id",
              async (_value, _context) => ["alpha", "beta"],
            ),
          ]),
          (),
        ),
      )
    let resourceTemplateHandle =
      server->McpServer.registerResourceTemplate(
        "memo",
        resourceTemplate,
        McpResource.makeConfig(~title="Memo", ~mimeType="text/plain", ()),
        async (uri, variables, _ctx) =>
          McpReadResourceResult.make([
            McpResourceContents.text(
              ~uri=Webapi.Url.href(uri),
              ~text=variables->variableId,
              (),
            ),
          ]),
      )

    await server->McpServer.connect(serverTransport)
    await client->McpClient.connectWithOptions(clientTransport, timeoutOptions)

    server->McpServer.isConnected->expect->Expect.toEqual(true)

    (await client->McpClient.listTools)
    ->McpTestBindings.listedTools
    ->expect
    ->Expect.toEqual([("echo", Some("Echo")), ("ping", Some("Ping"))])

    (await client->McpClient.listPrompts)
    ->McpTestBindings.listedPrompts
    ->expect
    ->Expect.toEqual([("review", Some("Review")), ("welcome", Some("Welcome"))])

    (await client->McpClient.listResources)
    ->McpTestBindings.listedResources
    ->expect
    ->Expect.toEqual([("config://app", "config")])

    (await client->McpClient.listResourceTemplates)
    ->McpTestBindings.listedResourceTemplates
    ->expect
    ->Expect.toEqual([("memo://{id}", "memo")])

    (
      await client->McpClient.ping
    )
    ->McpEmptyResult.meta
    ->expect
    ->Expect.toEqual(None)

    let initialToolResult = await client->McpClient.callTool(
      McpCallToolParams.make(
        ~name="echo",
        ~argumentValues=Dict.fromArray([("message", Json.string("hello"))]),
        (),
      ),
      echoOutputStandardSchema,
    )

    (
      initialToolResult->McpTestBindings.toolResultTexts,
      initialToolResult->McpCallToolResult.structuredContent->Option.map(output => output.sampled),
      initialToolResult->McpCallToolResult.structuredContent->Option.map(output => output.code),
      initialToolResult->McpCallToolResult.structuredContent->Option.map(output => output.root),
      initialToolResult->McpCallToolResult.structuredContent->Option.map(output => output.httpRequestMissing),
    )
    ->expect
    ->Expect.toEqual((
      ["hello|sampled-from-client|42|file:///workspace|tools/call"],
      Some("sampled-from-client"),
      Some("42"),
      Some("file:///workspace"),
      Some("true"),
    ))
    loggingNotifications.contents
    ->expect
    ->Expect.toEqual(["notice:tool-related", "info:tool invoked", "info:tool invoked with logger"])

    (await client->McpClient.callToolRaw(
      McpCallToolParams.make(~name="ping", ()),
    ))
    ->McpTestBindings.toolResultTextsRaw
    ->expect
    ->Expect.toEqual(["pong"])

    (await client->McpClient.getPrompt(
      McpGetPromptParams.make(~name="welcome", ()),
    ))
    ->McpTestBindings.promptResultTexts
    ->expect
    ->Expect.toEqual(["Welcome"])

    toolHandle->McpTool.update(
      McpTool.makeUpdates(
        ~title="Echo v2",
        ~outputSchema=echoOutputStandardSchema,
        ~callback=async (args, _ctx) =>
          McpCallToolResult.make(
            ~content=[McpContentBlock.text("updated:" ++ args.message)],
            ~structuredContent={
              sampled: args.message,
              code: "updated",
              root: "updated",
              httpRequestMissing: "true",
            },
            (),
          ),
        (),
      ),
    )
    pingHandle->McpTool.updateRaw0(
      McpTool.makeRawUpdates0(
        ~title="Ping v2",
        ~callback=async _ctx =>
          McpCallToolResult.makeRaw(~content=[McpContentBlock.text("pong-v2")], ()),
        (),
      ),
    )
    promptHandle->McpPrompt.update(
      McpPrompt.makeUpdates(
        ~title="Review v2",
        ~callback=async (args, _ctx) =>
          McpGetPromptResult.make(
            ~messages=[McpPromptMessage.text(~role=#assistant, ~text="Updated " ++ args.topic)],
            ~description="Updated prompt",
            (),
          ),
        (),
      ),
    )
    welcomeHandle->McpPrompt.update0(
      McpPrompt.makeUpdates0(
        ~title="Welcome v2",
        ~callback=async _ctx =>
          McpGetPromptResult.make(
            ~messages=[McpPromptMessage.text(~role=#assistant, ~text="Welcome v2")],
            (),
          ),
        (),
      ),
    )
    resourceHandle->McpResource.update(
      McpResource.makeUpdates(
        ~name="settings",
        ~uri="config://settings",
        ~callback=async (uri, _ctx) =>
          McpReadResourceResult.make([
            McpResourceContents.text(~uri=Webapi.Url.href(uri), ~text="{\"version\":2}", ()),
          ]),
        (),
      ),
    )
    let updatedTemplate =
      McpResourceTemplate.make(
        "memo://{id}/v2",
        McpResourceTemplate.makeCallbacks(~list=None, ()),
      )
    resourceTemplateHandle->McpResourceTemplate.update(
      McpResourceTemplate.makeUpdates(
        ~name="memo-v2",
        ~template=updatedTemplate,
        ~callback=async (uri, variables, _ctx) =>
          McpReadResourceResult.make([
            McpResourceContents.text(
              ~uri=Webapi.Url.href(uri),
              ~text=("updated:" ++ variables->variableId),
              (),
            ),
          ]),
        (),
      ),
    )
    await server->McpServer.sendLoggingMessage(
      McpLoggingMessageParams.make(
        ~level=#info,
        ~data="updated"->McpTestBindings.stringToUnknown,
        (),
      ),
    )
    await server->McpServer.sendLoggingMessageWithSessionId(
      McpLoggingMessageParams.make(
        ~level=#info,
        ~data="updated-session"->McpTestBindings.stringToUnknown,
        (),
      ),
      "loopback-session",
    )
    server->McpServer.sendResourceListChanged
    server->McpServer.sendToolListChanged
    server->McpServer.sendPromptListChanged
    loggingNotifications.contents
    ->expect
    ->Expect.toEqual([
      "notice:tool-related",
      "info:tool invoked",
      "info:tool invoked with logger",
      "info:updated",
      "info:updated-session",
    ])

    (await client->McpClient.listTools)
    ->McpTestBindings.listedTools
    ->expect
    ->Expect.toEqual([("echo", Some("Echo v2")), ("ping", Some("Ping v2"))])

    (await client->McpClient.listPrompts)
    ->McpTestBindings.listedPrompts
    ->expect
    ->Expect.toEqual([("review", Some("Review v2")), ("welcome", Some("Welcome v2"))])

    (await client->McpClient.listResources)
    ->McpTestBindings.listedResources
    ->expect
    ->Expect.toEqual([("config://settings", "settings")])

    (await client->McpClient.listResourceTemplates)
    ->McpTestBindings.listedResourceTemplates
    ->expect
    ->Expect.toEqual([("memo://{id}/v2", "memo-v2")])

    (await client->McpClient.callTool(
      McpCallToolParams.make(
        ~name="echo",
        ~argumentValues=Dict.fromArray([("message", Json.string("later"))]),
        (),
      ),
      echoOutputStandardSchema,
    ))
    ->McpTestBindings.toolResultTexts
    ->expect
    ->Expect.toEqual(["updated:later"])

    (await client->McpClient.callToolRaw(
      McpCallToolParams.make(~name="ping", ()),
    ))
    ->McpTestBindings.toolResultTextsRaw
    ->expect
    ->Expect.toEqual(["pong-v2"])

    let updatedPrompt = await client->McpClient.getPrompt(
      McpGetPromptParams.make(
        ~name="review",
        ~argumentValues=Dict.fromArray([("topic", "bindings")]),
        (),
      ),
    )
    (
      updatedPrompt->McpTestBindings.getPromptResultDescription,
      updatedPrompt->McpTestBindings.promptResultRoles,
      updatedPrompt->McpTestBindings.promptResultTexts,
    )
    ->expect
    ->Expect.toEqual((Some("Updated prompt"), [#assistant], ["Updated bindings"]))

    (await client->McpClient.getPrompt(
      McpGetPromptParams.make(~name="welcome", ()),
    ))
    ->McpTestBindings.promptResultTexts
    ->expect
    ->Expect.toEqual(["Welcome v2"])

    let updatedResource = await client->McpClient.readResource(
      McpResourceRequestParams.make(~uri="config://settings", ()),
    )
    (
      updatedResource->McpTestBindings.readResourceUris,
      updatedResource->McpTestBindings.readResourceTexts,
    )
    ->expect
    ->Expect.toEqual((["config://settings"], ["{\"version\":2}"]))

    let updatedTemplateResource = await client->McpClient.readResource(
      McpResourceRequestParams.make(~uri="memo://alpha/v2", ()),
    )
    updatedTemplateResource
    ->McpTestBindings.readResourceTexts
    ->expect
    ->Expect.toEqual(["updated:alpha"])

    await TestSupport.settle([
      (async () => client->McpClient.removeNotificationHandlerRaw(#message))(),
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      server->McpTestBindings.closeMcpServer->TestSupport.closeIgnore,
      serverTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
      clientTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })
})
