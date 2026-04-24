open Vitest
module S = RescriptSchema.S

@schema
type echoOutput = {echoed: string}

let echoOutputStandardSchema = echoOutputSchema->McpStandardSchema.fromRescriptSchema

describe("authoring roundtrip", () => {
  testAsync("authors tools, prompts, and resources in ReScript and uses them through the client bindings", async t => {
    let expect = value => t->expect(value)
    let client = McpTestBindings.makeClientWithOptions("stdio-authoring-client", "1.0.0")
    let transport = McpTestBindings.makeStdioClientTransport(
      TestSupport.execPath,
      [TestSupport.fixturePath("StdioAuthoringServer.mjs")],
      TestSupport.cwd,
    )

    await McpTestBindings.connectClientWithTimeout(client, transport, 5000)

    (await McpClient.listTools(client))->McpTestBindings.listedTools->expect->Expect.toEqual([
      ("echo", Some("Echo")),
    ])

    (await McpClient.listPrompts(client))->McpTestBindings.listedPrompts->expect->Expect.toEqual([
      ("review", Some("Review")),
    ])

    (await McpClient.listResources(client))
    ->McpTestBindings.listedResources
    ->expect
    ->Expect.toEqual([("config://app", "config")])

    let toolResult = await McpClient.callTool(
      client,
      McpCallToolParams.make(
        ~name="echo",
        ~argumentValues=Dict.fromArray([("message", Mcp.Protocol.JsonValue.string("hello"))]),
        (),
      ),
      echoOutputStandardSchema,
    )

    (
      toolResult->McpTestBindings.toolResultTexts,
      toolResult->McpCallToolResult.structuredContent->Option.map(output => output.echoed),
    )
    ->expect
    ->Expect.toEqual((["echo:hello"], Some("hello")))

    let promptResult = await McpClient.getPrompt(
      client,
      McpGetPromptParams.make(
        ~name="review",
        ~argumentValues=Dict.fromArray([("topic", "bindings")]),
        (),
      ),
    )

    (
      promptResult->McpTestBindings.getPromptResultDescription,
      promptResult->McpTestBindings.promptResultRoles,
      promptResult->McpTestBindings.promptResultTexts,
    )
    ->expect
    ->Expect.toEqual((Some("Review prompt"), [#user], ["Review bindings"]))

    let resourceResult = await McpClient.readResource(
      client,
      McpResourceRequestParams.make(~uri="config://app", ()),
    )

    (
      resourceResult->McpTestBindings.readResourceUris,
      resourceResult->McpTestBindings.readResourceTexts,
    )
    ->expect
    ->Expect.toEqual((["config://app"], ["{\"ok\":true}"]))

    await TestSupport.settle([
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      transport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })
})
