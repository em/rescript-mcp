open Vitest
module Json = Mcp.Protocol.JsonValue

type echoOutput = {echoed: string}
type nestedOutput = {nested: {name: string, score: float}}

@return(nullable)
@get
external rootContentBlockTextValue: Mcp.Protocol.ContentBlock.t => option<string> = "text"

describe("protocol surface", () => {
  test("content blocks and resource contents preserve discriminated variants", t => {
    let expect = value => t->expect(value)
    let textResource = McpResourceContents.text(~uri="resource://text", ~text="hello", ())
    let blobResource = McpResourceContents.blob(
      ~uri="resource://blob",
      ~blob="aGVsbG8=",
      ~mimeType="application/octet-stream",
      (),
    )
    let textBlock = McpContentBlock.text("hello")
    let imageBlock = McpContentBlock.image(~data="aGVsbG8=", ~mimeType="image/png")
    let audioBlock = McpContentBlock.audio(~data="aGVsbG8=", ~mimeType="audio/wav")
    let resourceLinkBlock = McpContentBlock.resourceLink(
      ~uri="resource://guide",
      ~name="guide",
      ~description="Guide",
      ~mimeType="text/plain",
      ~size=12.0,
    )
    let resourceBlock = McpContentBlock.resource(textResource)

    (
      Mcp.Protocol.Types.latestProtocolVersion == McpTypes.latestProtocolVersion,
      Mcp.Protocol.Types.defaultNegotiatedProtocolVersion == McpTypes.defaultNegotiatedProtocolVersion,
      Mcp.Protocol.Types.supportedProtocolVersions,
      Mcp.Core.ProtocolVersion.latest,
      Mcp.Core.ProtocolVersion.defaultNegotiated,
      McpTypes.latestProtocolVersion->McpProtocolVersion.toString,
      "2025-11-25"->McpProtocolVersion.fromString,
      textResource->McpResourceContents.kind,
      blobResource->McpResourceContents.kind,
      textBlock->McpContentBlock.kind,
      imageBlock->McpContentBlock.kind,
      audioBlock->McpContentBlock.kind,
      resourceLinkBlock->McpContentBlock.kind,
      resourceBlock->McpContentBlock.kind,
      textBlock->McpContentBlock.textValue,
      imageBlock->McpContentBlock.mimeType,
      resourceLinkBlock->McpContentBlock.uri,
      resourceBlock->McpContentBlock.resourceValue->Option.map(McpResourceContents.uri),
    )
    ->expect
    ->Expect.toEqual((
      true,
      true,
      McpProtocolVersion.supported,
      McpProtocolVersion.latest,
      McpProtocolVersion.defaultNegotiated,
      "2025-11-25",
      #v2025_11_25,
      #text,
      #blob,
      #text,
      #image,
      #audio,
      #resourceLink,
      #resource,
      Some("hello"),
      Some("image/png"),
      Some("resource://guide"),
      Some("resource://text"),
    ))
  })

  test("prompt and result wrappers preserve content, roles, and descriptions", t => {
    let expect = value => t->expect(value)
    let rootBlock = Mcp.Protocol.ContentBlock.text("root-entrypoint")
    let userMessage = McpPromptMessage.text(~role=#user, ~text="Review bindings")
    let toolResult = McpCallToolResult.make(
      ~content=[McpContentBlock.text("echo:hello")],
      ~structuredContent={echoed: "hello"},
      (),
    )
    let promptResult = McpGetPromptResult.make(
      ~messages=[userMessage],
      ~description="Review prompt",
      (),
    )
    let readResult = McpReadResourceResult.make([
      McpResourceContents.text(
        ~uri="config://app",
        ~text="{\"ok\":true}",
        ~mimeType="application/json",
        (),
      ),
    ])

    (
      rootBlock->rootContentBlockTextValue,
      userMessage->McpPromptMessage.role,
      userMessage->McpPromptMessage.content->McpContentBlock.textValue,
      toolResult->McpCallToolResult.content->Belt.Array.keepMap(McpContentBlock.textValue),
      toolResult->McpCallToolResult.structuredContent->Option.map(value => value.echoed),
      promptResult->McpGetPromptResult.description,
      promptResult->McpGetPromptResult.messages->Array.map(McpPromptMessage.role),
      promptResult
      ->McpGetPromptResult.messages
      ->Belt.Array.keepMap(message =>
          message->McpPromptMessage.content->McpContentBlock.textValue
        ),
      readResult->McpReadResourceResult.contents->Array.map(McpResourceContents.uri),
      readResult->McpReadResourceResult.contents->Belt.Array.keepMap(McpResourceContents.textValue),
    )
    ->expect
    ->Expect.toEqual((
      Some("root-entrypoint"),
      #user,
      Some("Review bindings"),
      ["echo:hello"],
      Some("hello"),
      Some("Review prompt"),
      [#user],
      ["Review bindings"],
      ["config://app"],
      ["{\"ok\":true}"],
    ))
  })

  test("call-tool payloads and tool schemas preserve the JSON value algebra", t => {
    let expect = value => t->expect(value)
    let params = McpCallToolParams.make(
      ~name="echo",
      ~argumentValues=Dict.fromArray([
        ("message", Json.string("hello")),
        ("count", Json.int(2)),
        ("ok", Json.bool(true)),
        ("tags", Json.array([Json.string("a"), Json.string("b")])),
      ]),
      (),
    )
    let result = McpCallToolResult.make(
      ~content=[McpContentBlock.text("ok")],
      ~structuredContent={nested: {name: "binding", score: 4.5}},
      (),
    )
    let schema =
      McpToolSchema.make(
        ~properties=Dict.fromArray([
          (
            "message",
            Json.object(
              Dict.fromArray([
                ("type", Json.string("string")),
                ("description", Json.string("Message text")),
              ]),
            ),
          ),
        ]),
        ~required=["message"],
        (),
      )

    (
      params->McpCallToolParams.argumentValues->Option.flatMap(dict =>
        dict->Dict.get("message")->Option.flatMap(value =>
          switch value {
          | Json.String(text) => Some(text)
          | _ => None
          }
        )
      ),
      params->McpCallToolParams.argumentValues->Option.flatMap(dict =>
        dict->Dict.get("count")->Option.flatMap(value =>
          switch value {
          | Json.Int(count) => Some(count)
          | _ => None
          }
        )
      ),
      result->McpCallToolResult.structuredContent->Option.map(value => value.nested.name),
      schema->McpToolSchema.properties->Option.flatMap(dict =>
        dict->Dict.get("message")->Option.flatMap(value =>
          switch value {
          | Json.Object(fields) =>
            fields->Dict.get("type")->Option.flatMap(value =>
              switch value {
              | Json.String(text) => Some(text)
              | _ => None
              }
            )
          | _ => None
          }
        )
      ),
      Json.object(Dict.fromArray([("active", Json.bool(true))]))
      ->Json.toJSON
      ->JSON.stringifyAny
      ->Option.getOr(""),
    )
    ->expect
    ->Expect.toEqual((Some("hello"), Some(2), Some("binding"), Some("string"), "{\"active\":true}"))
  })
})
