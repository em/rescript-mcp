// tests/fixtures/StdioAuthoringServer.res
// Concern: run a high-level stdio server that exercises tool, prompt, and static resource authoring from ReScript.
module Json = Mcp.Protocol.JsonValue

@schema
type echoArgs = {message: string}

@schema
type echoOutput = {echoed: string}

@schema
type promptArgs = {topic: string}

let server =
  McpServer.makeWithOptions(
    McpImplementation.make(~name="stdio-authoring-server", ~version="1.0.0"),
    McpServerOptions.make(~instructions="stdio authoring server", ()),
  )

let _tool =
  server->McpServer.registerTool(
    "echo",
    McpTool.makeConfig(
      ~title="Echo",
      ~description="Echoes the provided message",
      ~inputSchema=echoArgsSchema->McpStandardSchema.fromRescriptSchema,
      ~outputSchema=echoOutputSchema->McpStandardSchema.fromRescriptSchema,
      (),
    ),
    async (args, _ctx) =>
      McpCallToolResult.make(
        ~content=[McpContentBlock.text("echo:" ++ args.message)],
        ~structuredContent={echoed: args.message},
        (),
      ),
  )

let _prompt =
  server->McpServer.registerPrompt(
    "review",
    McpPrompt.makeConfig(
      ~title="Review",
      ~description="Creates a simple review prompt",
      ~argsSchema=promptArgsSchema->McpStandardSchema.fromRescriptSchema,
      (),
    ),
    async (args, _ctx) =>
      McpGetPromptResult.make(
        ~messages=[McpPromptMessage.text(~role=#user, ~text="Review " ++ args.topic)],
        ~description="Review prompt",
        (),
      ),
  )

let _resource =
  server->McpServer.registerResource(
    "config",
    "config://app",
    McpResource.makeConfig(
      ~title="Config",
      ~description="Static test config",
      ~mimeType="application/json",
      (),
    ),
    async (uri, _ctx) =>
      McpReadResourceResult.make([
        McpResourceContents.text(
          ~uri=Webapi.Url.href(uri),
          ~text="{\"ok\":true}",
          ~mimeType="application/json",
          (),
        ),
      ]),
  )

let _transport = McpStdioServerTransport.make()
let _connection = server->McpServer.connect(_transport)
