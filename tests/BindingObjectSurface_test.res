open Vitest
module S = RescriptSchema.S

@schema
type stringValue = @s.matches(S.string) string

@schema
type intValue = @s.matches(S.int) int

@obj
external makeServerContextFixture: (
  ~sessionId: string=?,
  ~mcpReq: unknown,
  ~http: unknown=?,
  ~task: McpTaskContext.t=?,
  (),
) => McpServerContext.t = ""

@obj
external makeServerContextMcpReqFixture: (
  ~id: McpTypes.requestId,
  ~method: string,
  ~_meta: dict<unknown>=?,
  ~signal: Webapi.Fetch.signal,
  ~send: unknown=?,
  ~notify: unknown=?,
  ~log: unknown=?,
  ~elicitInput: unknown=?,
  ~requestSampling: unknown=?,
  (),
) => unknown = ""

@obj
external makeServerContextHttpFixture: (
  ~authInfo: McpAuthInfo.t=?,
  ~req: Webapi.Fetch.Request.t=?,
  ~closeSSE: (unit => unit)=?,
  ~closeStandaloneSSE: (unit => unit)=?,
  (),
) => unknown = ""

@obj
external makeTaskContextFixture: (
  ~id: string=?,
  ~store: McpRequestTaskStore.t,
  ~requestedTtl: int=?,
  (),
) => McpTaskContext.t = ""

@obj
external makeRequestTaskStoreFixture: (
  ~createTask: unknown=?,
  ~getTask: unknown=?,
  ~storeTaskResult: unknown=?,
  ~getTaskResult: unknown=?,
  ~updateTaskStatus: unknown=?,
  ~listTasks: unknown=?,
  (),
) => McpRequestTaskStore.t = ""

@obj
external makeRequestHandlerExtraFixture: (
  ~authInfo: McpAuthInfo.t=?,
  ~sessionId: string=?,
  ~requestId: McpTypes.requestId,
  ~taskId: string=?,
  ~requestInfo: McpRequestInfo.t=?,
  ~closeSSEStream: (unit => unit)=?,
  ~closeStandaloneSSEStream: (unit => unit)=?,
  (),
) => McpRequestHandlerExtra.t = ""

@obj
external makeToolRegistered: (
  ~enable: unit => unit,
  ~disable: unit => unit,
  ~update: unknown => unit,
  ~remove: unit => unit,
  (),
) => McpTool.registered = ""

@obj
external makePromptRegistered: (
  ~enable: unit => unit,
  ~disable: unit => unit,
  ~update: unknown => unit,
  ~remove: unit => unit,
  (),
) => McpPrompt.registered = ""

@obj
external makeResourceRegistered: (
  ~enable: unit => unit,
  ~disable: unit => unit,
  ~update: unknown => unit,
  ~remove: unit => unit,
  (),
) => McpResource.registered = ""

@obj
external makeResourceTemplateRegistered: (
  ~enable: unit => unit,
  ~disable: unit => unit,
  ~update: unknown => unit,
  ~remove: unit => unit,
  (),
) => McpResourceTemplate.registered = ""

let stringField = (value, field) =>
  value->McpTestBindings.toDict->Dict.get(field)->Option.map(McpTestBindings.unknownToString)

let boolField = (value, field) =>
  value->McpTestBindings.toDict->Dict.get(field)->Option.map(McpTestBindings.unknownToBool)

let intField = (value, field) =>
  value->McpTestBindings.toDict->Dict.get(field)->Option.map(McpTestBindings.unknownToInt)

let floatField = (value, field) =>
  value->McpTestBindings.toDict->Dict.get(field)->Option.map(McpTestBindings.unknownToFloat)

describe("binding object surface", () => {
  testAsync("constructs public option and config objects through the package entrypoints", async t => {
    let expect = value => t->expect(value)
    let annotations = Dict.fromArray([("audience", "public"->McpTestBindings.stringToUnknown)])
    let meta = Dict.fromArray([("_owner", "binding-test"->McpTestBindings.stringToUnknown)])
    let capabilities = Dict.fromArray([("roots", "enabled"->McpTestBindings.stringToUnknown)])
    let taskStore = Mcp.Shared.TaskStore.makeInMemory()
    let taskQueue = Mcp.Shared.TaskMessageQueue.makeInMemory()
    let tasks =
      Mcp.Shared.TaskManagerOptions.make(
        ~taskStore,
        ~taskMessageQueue=taskQueue,
        ~defaultTaskPollInterval=1000,
        ~maxTaskQueueSize=8,
        (),
      )
    let taskParams = Mcp.Shared.TaskCreationParams.make(~ttl=5000, ~pollInterval=250, ())
    let relatedTask = Mcp.Shared.RelatedTaskMetadata.make(~taskId="task-42", ())
    let env = Dict.fromArray([("PATH", "/usr/bin")])
    let relatedRequestId = "request-42"->McpTestBindings.stringToUnknown
    let validator = "validator"->McpTestBindings.stringToUnknown
    let listChanged = "listChanged"->McpTestBindings.stringToUnknown
    let authProvider = "authProvider"->McpTestBindings.stringToUnknown
    let fetch = "fetch"->McpTestBindings.stringToUnknown
    let scheduler = "scheduler"->McpTestBindings.stringToUnknown
    let eventStore = "eventStore"->McpTestBindings.stringToUnknown
    let stderr = "pipe"->McpTestBindings.stringToUnknown
    let loggingData = "log-data"->McpTestBindings.stringToUnknown
    let requestInit = Webapi.Fetch.RequestInit.make(~method_=Webapi.Fetch.Post, ())
    let stringSchema: McpStandardSchema.t<string> = stringValueSchema->McpStandardSchema.fromRescriptSchema
    let intSchema: McpStandardSchema.t<int> = intValueSchema->McpStandardSchema.fromRescriptSchema
    let toolConfig = Mcp.Server.Tool.makeConfig(
      ~title="Echo",
      ~description="Echoes text",
      ~inputSchema=stringSchema,
      ~outputSchema=stringSchema,
      ~annotations,
      ~_meta=meta,
      (),
    )
    let promptConfig = Mcp.Server.Prompt.makeConfig(
      ~title="Summarize",
      ~description="Summarizes input",
      ~argsSchema=stringSchema,
      ~_meta=meta,
      (),
    )
    let resourceConfig = Mcp.Server.Resource.makeConfig(
      ~title="Guide",
      ~description="Binding guide",
      ~mimeType="text/plain",
      ~size=64.0,
      ~annotations,
      ~_meta=meta,
      (),
    )
    let protocolOptions = Mcp.Shared.ProtocolOptions.make(
      ~supportedProtocolVersions=[McpTypes.latestProtocolVersion],
      ~enforceStrictCapabilities=true,
      ~debouncedNotificationMethods=["notifications/message"],
      ~tasks,
      (),
    )
    let requestOptions = Mcp.Protocol.RequestOptions.make(
      ~onprogress=_ => (),
      ~signal="signal"->McpTestBindings.stringToUnknown,
      ~timeout=1000,
      ~resetTimeoutOnProgress=true,
      ~maxTotalTimeout=2000,
      ~task=taskParams,
      ~relatedTask,
      ~relatedRequestId,
      ~resumptionToken="resume-1",
      ~onresumptiontoken=_ => (),
      (),
    )
    let transportSendOptions = Mcp.Protocol.TransportSendOptions.make(
      ~relatedRequestId,
      ~resumptionToken="resume-1",
      ~onresumptiontoken=_ => (),
      (),
    )
    let loggingMessageParams = Mcp.Protocol.LoggingMessageParams.make(
      ~level=#info,
      ~data=loggingData,
      ~logger="binding-test",
      ~_meta=meta,
      (),
    )
    let resourceUpdatedParams = Mcp.Protocol.ResourceUpdatedParams.make(~uri="config://app", ~_meta=meta, ())
    let serverOptions = Mcp.Server.ServerOptions.make(
      ~capabilities,
      ~instructions="Server instructions",
      ~jsonSchemaValidator=validator,
      ~supportedProtocolVersions=[McpTypes.latestProtocolVersion],
      ~enforceStrictCapabilities=true,
      ~debouncedNotificationMethods=["notifications/resources/list_changed"],
      ~tasks,
      (),
    )
    let clientOptions = Mcp.Client.ClientOptions.make(
      ~capabilities,
      ~jsonSchemaValidator=validator,
      ~listChanged,
      ~supportedProtocolVersions=[McpTypes.latestProtocolVersion],
      ~enforceStrictCapabilities=true,
      ~debouncedNotificationMethods=["notifications/tools/list_changed"],
      ~tasks,
      (),
    )
    let reconnectionOptions: McpStreamableHttpReconnectionOptions.t =
      McpStreamableHttpReconnectionOptions.make(
      ~maxReconnectionDelay=5000,
      ~initialReconnectionDelay=250,
      ~reconnectionDelayGrowFactor=2.0,
      ~maxRetries=3,
      )
    let streamableHttpClientOptions: McpStreamableHttpClientTransportOptions.t =
      McpStreamableHttpClientTransportOptions.make(
        ~authProvider,
        ~requestInit,
        ~fetch,
        ~reconnectionOptions,
        ~reconnectionScheduler=scheduler,
        ~sessionId="session-1",
        ~protocolVersion=McpTypes.latestProtocolVersion,
        (),
      )
    let sseClientOptions = McpSSEClientTransportOptions.make(
      ~authProvider,
      ~requestInit,
      ~fetch,
      (),
    )
    let webTransportOptions = Mcp.Transports.WebStandardStreamableHttpServerTransportOptions.make(
      ~sessionIdGenerator=() => "session-1",
      ~onsessioninitialized=_ => (),
      ~onsessionclosed=_ => (),
      ~enableJsonResponse=true,
      ~eventStore,
      ~allowedHosts=["127.0.0.1"],
      ~allowedOrigins=["http://example.test"],
      ~enableDnsRebindingProtection=true,
      ~retryInterval=250,
      ~supportedProtocolVersions=[McpTypes.latestProtocolVersion],
      (),
    )
    let _nodeTransportOptions = Mcp.Transports.NodeStreamableHttpServerTransportOptions.make(
      ~sessionIdGenerator=() => "session-1",
      ~onsessioninitialized=_ => (),
      ~onsessionclosed=_ => (),
      ~enableJsonResponse=true,
      ~eventStore,
      ~allowedHosts=["127.0.0.1"],
      ~allowedOrigins=["http://example.test"],
      ~enableDnsRebindingProtection=true,
      ~retryInterval=250,
      ~supportedProtocolVersions=[McpTypes.latestProtocolVersion],
      (),
    )
    let _handleRequestOptions = Mcp.Transports.WebStandardStreamableHttpHandleRequestOptions.make(
      ~parsedBody=Dict.fromArray([("jsonrpc", "2.0"->McpTestBindings.stringToUnknown)])->McpTestBindings.dictToUnknown,
      ~authInfo=McpAuthInfo.make(~token="secret", ~clientId="client-1", ~scopes=["read"]),
      (),
    )
    let stdioServerParameters = Mcp.Transports.StdioServerParameters.make(
      ~command="node",
      ~args=["server.mjs"],
      ~env,
      ~stderr,
      ~cwd=TestSupport.cwd,
    )
    let httpClientTransport = Mcp.Transports.StreamableHttpClientTransport.makeWithOptions(
      Webapi.Url.make("http://127.0.0.1:65535/mcp"),
      streamableHttpClientOptions,
    )
    let sseClientTransport = Mcp.Transports.SSEClientTransport.makeWithOptions(
      Webapi.Url.make("http://127.0.0.1:65535/sse"),
      sseClientOptions,
    )
    let _stdioServerTransport = Mcp.Transports.StdioServerTransport.makeWithStreams(
      NodeJs.Process.stdin(TestSupport.process),
      NodeJs.Process.stdout(TestSupport.process),
    )
    let uriTemplate = Mcp.Shared.UriTemplate.make("memo://{id}")
    let queryTemplate = Mcp.Shared.UriTemplate.make("memo://{id}{?tag}")
    let resourceTemplate = Mcp.Server.ResourceTemplate.makeWithUriTemplate(
      uriTemplate,
      Mcp.Server.ResourceTemplate.makeCallbacks(
        ~list=Some(async _ctx =>
          Mcp.Protocol.ListResourcesResult.make(
            ~resources=[Mcp.Protocol.ListResourcesResult.makeResource(
              ~uri="memo://alpha",
              ~name="memo-alpha",
              (),
            )],
            (),
          )),
        ~complete=Dict.fromArray([
          (
            "id",
            async (_value, _context) => ["alpha", "beta"],
          ),
        ]),
        (),
      ),
    )

    httpClientTransport
    ->Mcp.Transports.StreamableHttpClientTransport.setProtocolVersion(McpTypes.latestProtocolVersion)
    sseClientTransport->Mcp.Transports.SSEClientTransport.setProtocolVersion(McpTypes.latestProtocolVersion)

    let resourceTemplateCompletions = switch resourceTemplate->Mcp.Server.ResourceTemplate.completeCallback("id") {
    | Some(callback) => await callback("a", None)
    | None => []
    }
    let listedTemplateResources = switch resourceTemplate->Mcp.Server.ResourceTemplate.listCallback {
    | Some(callback) =>
      await callback(
        makeServerContextFixture(
          ~mcpReq=makeServerContextMcpReqFixture(
            ~id=0->McpTestBindings.intToRequestId,
            ~method="resources/list",
            ~signal=Webapi.Fetch.AbortController.make()->Webapi.Fetch.AbortController.signal,
            (),
          ),
          (),
        ),
      )
    | None => Mcp.Protocol.ListResourcesResult.make(~resources=[], ())
    }
    let matchedTemplateId =
      switch uriTemplate->Mcp.Shared.UriTemplate.match("memo://alpha") {
      | Some(variables) =>
        switch variables->Dict.get("id") {
        | Some(Mcp.Shared.UriTemplate.Single(value)) => Some(value)
        | Some(Mcp.Shared.UriTemplate.Multiple(_)) | None => None
        }
      | None => None
      }
    let expandedTemplateUri =
      uriTemplate
      ->Mcp.Shared.UriTemplate.expand(Dict.fromArray([("id", Mcp.Shared.UriTemplate.Single("alpha"))]))
    let expandedQueryTemplateUri =
      queryTemplate
      ->Mcp.Shared.UriTemplate.expand(
        Dict.fromArray([
          ("id", Mcp.Shared.UriTemplate.Single("alpha")),
          ("tag", Mcp.Shared.UriTemplate.Multiple(["x", "y"])),
        ]),
      )

    (
      stringField(toolConfig, "title"),
      stringField(promptConfig, "title"),
      stringField(resourceConfig, "mimeType"),
      floatField(resourceConfig, "size"),
      stringField(serverOptions, "instructions"),
      boolField(serverOptions, "enforceStrictCapabilities"),
      boolField(clientOptions, "enforceStrictCapabilities"),
      intField(requestOptions, "timeout"),
      stringField(transportSendOptions, "resumptionToken"),
      loggingMessageParams->Mcp.Protocol.LoggingMessageParams.level,
      loggingMessageParams->Mcp.Protocol.LoggingMessageParams.data->McpTestBindings.unknownToString,
      loggingMessageParams->Mcp.Protocol.LoggingMessageParams.logger,
      loggingMessageParams
      ->Mcp.Protocol.LoggingMessageParams.meta
      ->Option.flatMap(meta => meta->Dict.get("_owner")->Option.map(McpTestBindings.unknownToString)),
      resourceUpdatedParams->Mcp.Protocol.ResourceUpdatedParams.uri,
      resourceUpdatedParams
      ->Mcp.Protocol.ResourceUpdatedParams.meta
      ->Option.flatMap(meta => meta->Dict.get("_owner")->Option.map(McpTestBindings.unknownToString)),
      boolField(protocolOptions, "enforceStrictCapabilities"),
      stringField(streamableHttpClientOptions, "sessionId"),
      stringField(streamableHttpClientOptions, "protocolVersion"),
      boolField(webTransportOptions, "enableJsonResponse"),
      intField(webTransportOptions, "retryInterval"),
      stringField(stdioServerParameters, "command"),
      intField(requestOptions, "maxTotalTimeout"),
      requestOptions->McpTestBindings.toDict->Dict.get("task") != None,
      requestOptions
      ->McpTestBindings.toDict
      ->Dict.get("relatedTask")
      ->Option.flatMap(value =>
          value
          ->McpTestBindings.toDict
          ->Dict.get("taskId")
          ->Option.map(McpTestBindings.unknownToString)
        ),
      httpClientTransport->Mcp.Transports.StreamableHttpClientTransport.protocolVersion,
      uriTemplate->Mcp.Shared.UriTemplate.variableNames,
      expandedTemplateUri,
      matchedTemplateId,
      expandedQueryTemplateUri,
      resourceTemplate->Mcp.Server.ResourceTemplate.uriTemplate->Mcp.Shared.UriTemplate.toString,
      listedTemplateResources->McpTestBindings.listedResources,
      resourceTemplateCompletions,
      intSchema->McpTestBindings.toDict->Dict.get("~standard") != None,
    )
    ->expect
    ->Expect.toEqual((
      Some("Echo"),
      Some("Summarize"),
      Some("text/plain"),
      Some(64.0),
      Some("Server instructions"),
      Some(true),
      Some(true),
      Some(1000),
      Some("resume-1"),
      #info,
      "log-data",
      Some("binding-test"),
      Some("binding-test"),
      "config://app",
      Some("binding-test"),
      Some(true),
      Some("session-1"),
      Some(McpTypes.latestProtocolVersion->McpProtocolVersion.toString),
      Some(true),
      Some(250),
      Some("node"),
      Some(2000),
      true,
      Some("task-42"),
      Some(McpTypes.latestProtocolVersion),
      ["id"],
      "memo://alpha",
      Some("alpha"),
      "memo://alpha?tag=x,y",
      "memo://{id}",
      [("memo://alpha", "memo-alpha")],
      ["alpha", "beta"],
      true,
    ))
  })

  test("reads public context objects and dispatches registered binding controls", t => {
    let expect = value => t->expect(value)
    let requestId = 7->McpTestBindings.intToRequestId
    let closeCount = ref(0)
    let standaloneCloseCount = ref(0)
    let request = Webapi.Fetch.Request.make("https://example.test/request")
    let abortController = Webapi.Fetch.AbortController.make()
    let requestInfo = McpRequestInfo.make(
      ~headers=Dict.fromArray([("accept", "application/json"->McpTestBindings.stringToUnknown)]),
      ~url=Webapi.Url.make("https://example.test/request"),
      (),
    )
    let authInfo = Mcp.Auth.Info.make(
      ~token="secret",
      ~clientId="client-1",
      ~scopes=["read", "write"],
      ~expiresAt=12345.0,
      ~resource=Webapi.Url.make("https://example.test/resource"),
      ~extra=Dict.fromArray([("tenant", "acme"->McpTestBindings.stringToUnknown)]),
    )
    let messageExtra = McpMessageExtraInfo.make(
      ~request,
      ~authInfo,
      ~closeSSEStream=() => closeCount := closeCount.contents + 1,
      ~closeStandaloneSSEStream=() => standaloneCloseCount := standaloneCloseCount.contents + 1,
      (),
    )
    let requestHandlerExtra = makeRequestHandlerExtraFixture(
      ~authInfo,
      ~sessionId="session-1",
      ~requestId,
      ~taskId="task-1",
      ~requestInfo,
      ~closeSSEStream=() => closeCount := closeCount.contents + 1,
      ~closeStandaloneSSEStream=() => standaloneCloseCount := standaloneCloseCount.contents + 1,
      (),
    )
    let requestTaskStore =
      makeRequestTaskStoreFixture(
        ~createTask=(async _params => JsError.throwWithMessage("unused"))->McpTestBindings.toUnknown,
        ~getTask=(async _taskId => JsError.throwWithMessage("unused"))->McpTestBindings.toUnknown,
        ~storeTaskResult=((async (_taskId, _status, _result) => ()))->McpTestBindings.toUnknown,
        ~getTaskResult=(async _taskId => "unused"->McpTestBindings.stringToUnknown)->McpTestBindings.toUnknown,
        ~updateTaskStatus=((async (_taskId, _status, _statusMessage) => ()))->McpTestBindings.toUnknown,
        ~listTasks=(async _cursor => McpListTasksResult.make(~tasks=[], ()))->McpTestBindings.toUnknown,
        (),
      )
    let serverContext = makeServerContextFixture(
      ~sessionId="session-1",
      ~mcpReq=makeServerContextMcpReqFixture(
        ~id=requestId,
        ~method="tools/call",
        ~_meta=Dict.fromArray([("origin", "binding-test"->McpTestBindings.stringToUnknown)]),
        ~signal=abortController->Webapi.Fetch.AbortController.signal,
        (),
      ),
      ~http=makeServerContextHttpFixture(
        ~authInfo,
        ~req=request,
        ~closeSSE=() => closeCount := closeCount.contents + 1,
        ~closeStandaloneSSE=() => standaloneCloseCount := standaloneCloseCount.contents + 1,
        (),
      ),
      ~task=makeTaskContextFixture(~id="task-1", ~store=requestTaskStore, ~requestedTtl=60000, ()),
      (),
    )
    let toolCounts = ref((0, 0, 0, 0))
    let promptCounts = ref((0, 0, 0, 0))
    let resourceCounts = ref((0, 0, 0, 0))
    let resourceTemplateCounts = ref((0, 0, 0, 0))
    let toolRegistered = makeToolRegistered(
      ~enable=() => toolCounts := switch toolCounts.contents { | (e, d, u, r) => (e + 1, d, u, r) },
      ~disable=() => toolCounts := switch toolCounts.contents { | (e, d, u, r) => (e, d + 1, u, r) },
      ~update=_ => toolCounts := switch toolCounts.contents { | (e, d, u, r) => (e, d, u + 1, r) },
      ~remove=() => toolCounts := switch toolCounts.contents { | (e, d, u, r) => (e, d, u, r + 1) },
      (),
    )
    let promptRegistered = makePromptRegistered(
      ~enable=() => promptCounts := switch promptCounts.contents { | (e, d, u, r) => (e + 1, d, u, r) },
      ~disable=() => promptCounts := switch promptCounts.contents { | (e, d, u, r) => (e, d + 1, u, r) },
      ~update=_ => promptCounts := switch promptCounts.contents { | (e, d, u, r) => (e, d, u + 1, r) },
      ~remove=() => promptCounts := switch promptCounts.contents { | (e, d, u, r) => (e, d, u, r + 1) },
      (),
    )
    let resourceRegistered = makeResourceRegistered(
      ~enable=() => resourceCounts := switch resourceCounts.contents { | (e, d, u, r) => (e + 1, d, u, r) },
      ~disable=() => resourceCounts := switch resourceCounts.contents { | (e, d, u, r) => (e, d + 1, u, r) },
      ~update=_ => resourceCounts := switch resourceCounts.contents { | (e, d, u, r) => (e, d, u + 1, r) },
      ~remove=() => resourceCounts := switch resourceCounts.contents { | (e, d, u, r) => (e, d, u, r + 1) },
      (),
    )
    let resourceTemplateRegistered = makeResourceTemplateRegistered(
      ~enable=() => resourceTemplateCounts := switch resourceTemplateCounts.contents { | (e, d, u, r) => (e + 1, d, u, r) },
      ~disable=() => resourceTemplateCounts := switch resourceTemplateCounts.contents { | (e, d, u, r) => (e, d + 1, u, r) },
      ~update=_ => resourceTemplateCounts := switch resourceTemplateCounts.contents { | (e, d, u, r) => (e, d, u + 1, r) },
      ~remove=() => resourceTemplateCounts := switch resourceTemplateCounts.contents { | (e, d, u, r) => (e, d, u, r + 1) },
      (),
    )

    switch messageExtra->McpMessageExtraInfo.closeSSEStream {
    | Some(close) => close()
    | None => ()
    }
    switch requestHandlerExtra->McpRequestHandlerExtra.closeStandaloneSSEStream {
    | Some(close) => close()
    | None => ()
    }

    toolRegistered->McpTool.enable
    toolRegistered->McpTool.disable
    toolRegistered->McpTool.update(
      McpTool.makeUpdates(
        ~title="Updated echo",
        ~outputSchema=stringValueSchema->McpStandardSchema.fromRescriptSchema,
        (),
      ),
    )
    toolRegistered->McpTool.remove
    promptRegistered->McpPrompt.enable
    promptRegistered->McpPrompt.disable
    promptRegistered->McpPrompt.update(McpPrompt.makeUpdates(~title="Updated prompt", ()))
    promptRegistered->McpPrompt.remove
    resourceRegistered->McpResource.enable
    resourceRegistered->McpResource.disable
    resourceRegistered->McpResource.update(McpResource.makeUpdates(~title="Updated resource", ()))
    resourceRegistered->McpResource.remove
    resourceTemplateRegistered->Mcp.Server.ResourceTemplate.enable
    resourceTemplateRegistered->Mcp.Server.ResourceTemplate.disable
    resourceTemplateRegistered
    ->Mcp.Server.ResourceTemplate.update(
      Mcp.Server.ResourceTemplate.makeUpdates(~title="Updated template", ~enabled=true, ()),
    )
    resourceTemplateRegistered->Mcp.Server.ResourceTemplate.remove

    switch serverContext->McpServerContext.closeSSE {
    | Some(close) => close()
    | None => ()
    }
    switch serverContext->McpServerContext.closeStandaloneSSE {
    | Some(close) => close()
    | None => ()
    }

    (
      authInfo->stringField("token"),
      authInfo->stringField("clientId"),
      authInfo->floatField("expiresAt"),
      requestInfo->McpRequestInfo.headers->Dict.get("accept")->Option.map(McpTestBindings.unknownToString),
      requestInfo->McpRequestInfo.url->Option.map(Webapi.Url.href),
      messageExtra->McpMessageExtraInfo.request == Some(request),
      messageExtra->McpMessageExtraInfo.authInfo == Some(authInfo),
      requestHandlerExtra->McpRequestHandlerExtra.sessionId,
      requestHandlerExtra->McpRequestHandlerExtra.requestId->McpTestBindings.requestIdToInt,
      requestHandlerExtra->McpRequestHandlerExtra.taskId,
      serverContext->McpServerContext.sessionId,
      serverContext->McpServerContext.task->Option.flatMap(McpTaskContext.id),
      serverContext->McpServerContext.task->Option.flatMap(McpTaskContext.requestedTtl),
      serverContext->McpServerContext.requestId->McpTestBindings.requestIdToInt,
      serverContext->McpServerContext.requestMethod,
      serverContext
      ->McpServerContext.requestMeta
      ->Option.flatMap(meta => meta->Dict.get("origin")->Option.map(McpTestBindings.unknownToString)),
      serverContext->McpServerContext.requestSignal == abortController->Webapi.Fetch.AbortController.signal,
      serverContext->McpServerContext.httpAuthInfo == Some(authInfo),
      serverContext->McpServerContext.httpRequest == Some(request),
      closeCount.contents,
      standaloneCloseCount.contents,
      toolCounts.contents,
      promptCounts.contents,
      resourceCounts.contents,
      resourceTemplateCounts.contents,
    )
    ->expect
    ->Expect.toEqual((
      Some("secret"),
      Some("client-1"),
      Some(12345.0),
      Some("application/json"),
      Some("https://example.test/request"),
      true,
      true,
      Some("session-1"),
      7,
      Some("task-1"),
      Some("session-1"),
      Some("task-1"),
      Some(60000),
      7,
      #toolsCall,
      Some("binding-test"),
      true,
      true,
      true,
      2,
      2,
      (1, 1, 1, 1),
      (1, 1, 1, 1),
      (1, 1, 1, 1),
      (1, 1, 1, 1),
    ))
  })
})
