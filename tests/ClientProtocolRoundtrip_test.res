open Vitest
module Json = Mcp.Protocol.JsonValue

module S = RescriptSchema.S

@schema
type echoOutput = {echoed: string}

@get external requestParams: unknown => unknown = "params"

@return(nullable) @get external paramsCursor: unknown => option<string> = "cursor"
@get external paramsName: unknown => string = "name"
@get external paramsUri: unknown => string = "uri"
@return(nullable) @get external paramsPromptArguments: unknown => option<dict<string>> = "arguments"
@return(nullable) @get external paramsToolArguments: unknown => option<dict<unknown>> = "arguments"
@get external paramsLevel: unknown => string = "level"
@get external paramsCompleteArgument: unknown => unknown = "argument"
@get external completeArgumentName: unknown => string = "name"
@get external completeArgumentValue: unknown => string = "value"

let promptTopic = request =>
  request
  ->requestParams
  ->paramsPromptArguments
  ->Option.flatMap(args => args->Dict.get("topic"))
  ->Option.getOr("missing")

let toolMessage = request =>
  request
  ->requestParams
  ->paramsToolArguments
  ->Option.flatMap(args => args->Dict.get("message")->Option.map(McpTestBindings.unknownToString))
  ->Option.getOr("missing")

let resolveUnknown = value => Promise.resolve(value->McpTestBindings.toUnknown)
let getOrThrow = Option.getOrThrow

let echoOutputStandardSchema = echoOutputSchema->McpStandardSchema.fromRescriptSchema

describe("client protocol roundtrip", () => {
  testAsync("typed client params and results roundtrip through the installed low-level protocol surface", async t => {
    let expect = value => t->expect(value)
    let server = McpTestBindings.makeLowLevelServer("client-protocol-server", "1.0.0")
    let serverCapabilities =
      Dict.fromArray([
        ("logging", Dict.fromArray([])->McpTestBindings.dictToUnknown),
        ("completions", Dict.fromArray([])->McpTestBindings.dictToUnknown),
        ("prompts", Dict.fromArray([])->McpTestBindings.dictToUnknown),
        (
          "resources",
          Dict.fromArray([
            ("subscribe", true->McpTestBindings.boolToUnknown),
            ("listChanged", true->McpTestBindings.boolToUnknown),
          ])
          ->McpTestBindings.dictToUnknown,
        ),
        (
          "tools",
          Dict.fromArray([("listChanged", true->McpTestBindings.boolToUnknown)])
          ->McpTestBindings.dictToUnknown,
        ),
      ])
    server->McpLowLevelServer.registerCapabilities(serverCapabilities)

    server->McpLowLevelServer.setRequestHandlerRaw(
      #completionComplete,
      (request, _extra) =>
        resolveUnknown(
          McpCompleteResult.make(
            ~completion=McpCompleteResult.makeCompletion(
              ~values=[
                request->requestParams->paramsCompleteArgument->completeArgumentValue,
                request->requestParams->paramsCompleteArgument->completeArgumentName,
              ],
              ~total=2.0,
              ~hasMore=false,
              (),
            ),
            (),
          ),
        ),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #loggingSetLevel,
      (_request, _extra) => resolveUnknown(McpEmptyResult.make(())),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #promptsGet,
      (request, _extra) =>
        resolveUnknown(
          McpGetPromptResult.make(
            ~messages=[McpPromptMessage.text(~role=#assistant, ~text=`prompt:${request->requestParams->paramsName}:${request->promptTopic}`)],
            ~description=`prompt:${request->requestParams->paramsName}`,
            (),
          ),
        ),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #promptsList,
      (request, _extra) =>
        resolveUnknown(
          McpListPromptsResult.make(
            ~prompts=[McpListPromptsResult.makePrompt(
              ~name="review",
              ~title=request->requestParams->paramsCursor->Option.getOr("no-cursor"),
              ~description="Prompt description",
              ~argumentList=[McpListPromptsResult.makePromptArgument(
                ~name="topic",
                ~description="Prompt topic",
                ~required=true,
                (),
              )],
              ~icons=[McpIcon.make(~src="prompt.svg", ~theme=#light, ())],
              (),
            )],
            ~nextCursor="prompts-next",
            (),
          ),
        ),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #resourcesList,
      (request, _extra) =>
        resolveUnknown(
          McpListResourcesResult.make(
            ~resources=[McpListResourcesResult.makeResource(
              ~uri="config://typed",
              ~name="typed-resource",
              ~title=request->requestParams->paramsCursor->Option.getOr("no-cursor"),
              ~description="Resource description",
              ~mimeType="application/json",
              ~size=32.0,
              ~annotations=McpAnnotations.make(~audience=[#assistant], ~priority=0.75, ~lastModified="2026-04-23T00:00:00Z", ()),
              ~icons=[McpIcon.make(~src="resource.svg", ~theme=#dark, ())],
              (),
            )],
            ~nextCursor="resources-next",
            (),
          ),
        ),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #resourcesTemplatesList,
      (request, _extra) =>
        resolveUnknown(
          McpListResourceTemplatesResult.make(
            ~resourceTemplates=[McpListResourceTemplatesResult.makeResourceTemplate(
              ~uriTemplate="memo://{id}",
              ~name="memo",
              ~title=request->requestParams->paramsCursor->Option.getOr("no-cursor"),
              ~description="Template description",
              ~mimeType="text/plain",
              ~annotations=McpAnnotations.make(~audience=[#user], ~priority=0.5, ~lastModified="2026-04-23T00:00:00Z", ()),
              ~icons=[McpIcon.make(~src="template.svg", ~theme=#light, ())],
              (),
            )],
            ~nextCursor="templates-next",
            (),
          ),
        ),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #resourcesRead,
      (request, _extra) =>
        resolveUnknown(
          McpReadResourceResult.make([
            McpResourceContents.text(
              ~uri=request->requestParams->paramsUri,
              ~text=`read:${request->requestParams->paramsUri}`,
              (),
            ),
          ]),
        ),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #resourcesSubscribe,
      (_request, _extra) => resolveUnknown(McpEmptyResult.make(())),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #resourcesUnsubscribe,
      (_request, _extra) => resolveUnknown(McpEmptyResult.make(())),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #toolsCall,
      (request, _extra) =>
        resolveUnknown(
          McpCallToolResult.makeRaw(
            ~content=[McpContentBlock.text(`tool:${request->requestParams->paramsName}:${request->toolMessage}`)],
            ~structuredContent=Dict.fromArray([("echoed", Json.string(request->toolMessage))]),
            (),
          ),
        ),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #toolsList,
      (request, _extra) =>
        resolveUnknown(
          McpListToolsResult.make(
            ~tools=[McpListToolsResult.makeTool(
              ~name="echo",
              ~title=request->requestParams->paramsCursor->Option.getOr("no-cursor"),
              ~description="Tool description",
              ~inputSchema=McpToolSchema.make(
                ~properties=Dict.fromArray([(
                  "message",
                  Json.object(Dict.fromArray([("type", Json.string("string"))])),
                )]),
                ~required=["message"],
                (),
              ),
              ~outputSchema=McpToolSchema.make(
                ~properties=Dict.fromArray([(
                  "echoed",
                  Json.object(Dict.fromArray([("type", Json.string("string"))])),
                )]),
                ~required=["echoed"],
                (),
              ),
              ~annotations=McpListToolsResult.makeAnnotations(
                ~title="Tool title",
                ~readOnlyHint=true,
                ~destructiveHint=false,
                ~idempotentHint=true,
                ~openWorldHint=false,
                (),
              ),
              ~execution=McpListToolsResult.makeExecution(~taskSupport=#optional, ()),
              ~icons=[McpIcon.make(~src="tool.svg", ~theme=#dark, ())],
              (),
            )],
            ~nextCursor="tools-next",
            (),
          ),
        ),
    )

    let client = McpTestBindings.makeClient("client-protocol-client", "1.0.0")
    client->McpTestBindings.registerClientCapabilities(
      Dict.fromArray([("roots", Dict.fromArray([])->McpTestBindings.dictToUnknown)]),
    )
    client->McpTestBindings.setClientRequestHandlerRaw(
      #rootsList,
      (_request, _ctx) =>
        resolveUnknown(
          McpListRootsResult.make(
            ~roots=[McpListRootsResult.makeRoot(~uri="file:///workspace", ~name="workspace", ())],
            (),
          ),
        ),
    )

    let pair = McpTestBindings.makeLoopbackTransportPair("client-protocol")
    let serverTransport = pair->McpTestBindings.loopbackServerTransport
    let clientTransport = pair->McpTestBindings.loopbackClientTransport
    let timeoutOptions = McpRequestOptions.make(~timeout=5000, ())

    await server->McpLowLevelServer.connect(serverTransport)
    await client->McpClient.connectWithOptions(clientTransport, timeoutOptions)

    let pingResult = await client->McpClient.pingWithOptions(timeoutOptions)
    let completionResult =
      await client->McpClient.completeWithOptions(
        McpCompleteParams.makeWithPrompt(
          ~ref=McpCompleteParams.promptReference("review"),
          ~argument=McpCompleteParams.makeArgument(~name="topic", ~value="bindings", ()),
          (),
        ),
        timeoutOptions,
      )
    let loggingResult = await client->McpClient.setLoggingLevelWithOptions(#warning, timeoutOptions)
    let promptResult =
      await client->McpClient.getPromptWithOptions(
        McpGetPromptParams.make(~name="review", ~argumentValues=Dict.fromArray([("topic", "bindings")]), ()),
        timeoutOptions,
      )
    let promptsResult =
      await client->McpClient.listPromptsWithParamsAndOptions(
        McpPaginatedParams.make(~cursor="prompt-cursor", ()),
        timeoutOptions,
      )
    let resourcesResult =
      await client->McpClient.listResourcesWithParamsAndOptions(
        McpPaginatedParams.make(~cursor="resource-cursor", ()),
        timeoutOptions,
      )
    let resourceTemplatesResult =
      await client->McpClient.listResourceTemplatesWithParamsAndOptions(
        McpPaginatedParams.make(~cursor="template-cursor", ()),
        timeoutOptions,
      )
    let readResult =
      await client->McpClient.readResourceWithOptions(
        McpResourceRequestParams.make(~uri="config://typed", ()),
        timeoutOptions,
      )
    let subscribeResult = await client->McpClient.subscribeResource(McpResourceRequestParams.make(~uri="config://typed", ()))
    let unsubscribeResult =
      await client->McpClient.unsubscribeResourceWithOptions(
        McpResourceRequestParams.make(~uri="config://typed", ()),
        timeoutOptions,
      )
    let toolResult =
      await client->McpClient.callToolWithOptions(
        McpCallToolParams.make(
          ~name="echo",
          ~argumentValues=Dict.fromArray([("message", Json.string("hello"))]),
          (),
        ),
        echoOutputStandardSchema,
        timeoutOptions,
      )
    let toolsResult =
      await client->McpClient.listToolsWithParamsAndOptions(
        McpPaginatedParams.make(~cursor="tool-cursor", ()),
        timeoutOptions,
      )
    let rootsResult =
      await server->McpLowLevelServer.listRootsWithParamsAndOptions(McpListRootsParams.make(()), timeoutOptions)

    let listedPrompt = promptsResult->McpListPromptsResult.prompts->Array.get(0)->getOrThrow
    let listedPromptArgument =
      listedPrompt->McpListPromptsResult.promptArguments->getOrThrow->Array.get(0)->getOrThrow
    let listedResource = resourcesResult->McpListResourcesResult.resources->Array.get(0)->getOrThrow
    let listedTemplate =
      resourceTemplatesResult
      ->McpListResourceTemplatesResult.resourceTemplates
      ->Array.get(0)
      ->getOrThrow
    let listedTool = toolsResult->McpListToolsResult.tools->Array.get(0)->getOrThrow
    let toolAnnotations = listedTool->McpListToolsResult.toolAnnotations->getOrThrow
    let toolExecution = listedTool->McpListToolsResult.toolExecution->getOrThrow
    let listedRoot = rootsResult->McpListRootsResult.roots->Array.get(0)->getOrThrow

    (
      pingResult->McpEmptyResult.meta,
      completionResult->McpCompleteResult.completion->McpCompleteResult.values,
      completionResult->McpCompleteResult.completion->McpCompleteResult.total,
      completionResult->McpCompleteResult.completion->McpCompleteResult.hasMore,
      loggingResult->McpEmptyResult.meta,
      promptResult->McpGetPromptResult.description,
      promptResult->McpTestBindings.promptResultTexts,
      promptsResult->McpListPromptsResult.nextCursor,
      listedPrompt->McpListPromptsResult.promptTitle,
      listedPromptArgument->McpListPromptsResult.argumentDescription,
      listedPromptArgument->McpListPromptsResult.argumentRequired,
      resourcesResult->McpListResourcesResult.nextCursor,
      listedResource->McpListResourcesResult.title,
      listedResource->McpListResourcesResult.mimeType,
      listedResource->McpListResourcesResult.size,
      listedResource->McpListResourcesResult.annotations->Option.flatMap(McpAnnotations.priority),
      listedResource->McpListResourcesResult.icons->getOrThrow->Array.get(0)->getOrThrow->McpIcon.theme,
      resourceTemplatesResult->McpListResourceTemplatesResult.nextCursor,
      listedTemplate->McpListResourceTemplatesResult.title,
      listedTemplate->McpListResourceTemplatesResult.annotations->Option.flatMap(McpAnnotations.audience),
      readResult->McpTestBindings.readResourceTexts,
      subscribeResult->McpEmptyResult.meta,
      unsubscribeResult->McpEmptyResult.meta,
      toolResult->McpTestBindings.toolResultTexts,
      toolResult->McpCallToolResult.structuredContent->Option.map(output => output.echoed),
      toolsResult->McpListToolsResult.nextCursor,
      listedTool->McpListToolsResult.title,
      listedTool->McpListToolsResult.inputSchema->McpToolSchema.kind,
      listedTool->McpListToolsResult.inputSchema->McpToolSchema.required,
      listedTool->McpListToolsResult.outputSchema->Option.map(schema => schema->McpToolSchema.required),
      toolAnnotations->McpListToolsResult.annotationTitle,
      toolAnnotations->McpListToolsResult.readOnlyHint,
      toolAnnotations->McpListToolsResult.idempotentHint,
      toolExecution->McpListToolsResult.taskSupport,
      listedTool->McpListToolsResult.icons->getOrThrow->Array.get(0)->getOrThrow->McpIcon.theme,
      listedRoot->McpListRootsResult.uri,
      listedRoot->McpListRootsResult.name,
    )
    ->expect
    ->Expect.toEqual((
      None,
      ["bindings", "topic"],
      Some(2.0),
      Some(false),
      None,
      Some("prompt:review"),
      ["prompt:review:bindings"],
      Some("prompts-next"),
      Some("prompt-cursor"),
      Some("Prompt topic"),
      Some(true),
      Some("resources-next"),
      Some("resource-cursor"),
      Some("application/json"),
      Some(32.0),
      Some(0.75),
      Some(#dark),
      Some("templates-next"),
      Some("template-cursor"),
      Some([#user]),
      ["read:config://typed"],
      None,
      None,
      ["tool:echo:hello"],
      Some("hello"),
      Some("tools-next"),
      Some("tool-cursor"),
      #object,
      Some(["message"]),
      Some(Some(["echoed"])),
      Some("Tool title"),
      Some(true),
      Some(true),
      Some(#optional),
      Some(#dark),
      "file:///workspace",
      Some("workspace"),
    ))

    await TestSupport.settle([
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      server->McpTestBindings.closeLowLevelServer->TestSupport.closeIgnore,
      serverTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
      clientTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })

  testAsync("typed client tool decoding rejects structured output that does not match the public schema", async t => {
    let expect = value => t->expect(value)
    let server = McpTestBindings.makeLowLevelServer("client-protocol-mismatch-server", "1.0.0")
    let client = McpTestBindings.makeClient("client-protocol-mismatch-client", "1.0.0")
    let pair = McpTestBindings.makeLoopbackTransportPair("client-protocol-mismatch")
    let serverTransport = pair->McpTestBindings.loopbackServerTransport
    let clientTransport = pair->McpTestBindings.loopbackClientTransport
    let timeoutOptions = McpRequestOptions.make(~timeout=5000, ())

    server->McpLowLevelServer.registerCapabilities(
      Dict.fromArray([("tools", Dict.fromArray([])->McpTestBindings.dictToUnknown)]),
    )

    server->McpLowLevelServer.setRequestHandlerRaw(
      #toolsCall,
      (_request, _extra) =>
        resolveUnknown(
          McpCallToolResult.makeRaw(
            ~content=[McpContentBlock.text("tool:mismatch")],
            ~structuredContent=Dict.fromArray([("count", Json.int(1))]),
            (),
          ),
        ),
    )

    await server->McpLowLevelServer.connect(serverTransport)
    await client->McpClient.connectWithOptions(clientTransport, timeoutOptions)

    await client
    ->McpClient.callToolWithOptions(
        McpCallToolParams.make(~name="echo", ()),
        echoOutputStandardSchema,
        timeoutOptions,
      )
    ->expect
    ->Expect.Promise.rejects
    ->Expect.Promise.toThrow

    await TestSupport.settle([
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      server->McpTestBindings.closeLowLevelServer->TestSupport.closeIgnore,
      serverTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
      clientTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })
})
