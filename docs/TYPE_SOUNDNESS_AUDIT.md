# Type Soundness Audit

**BUILD PASSING.** `npm run build`, `npm test`, and `npm pack --dry-run` pass on 2026-04-24 after the typed tool-output, typed client result-classification, typed task-result storage, and finite protocol-version control work.

## Scope

This audit covers the non-trivial public binding changes in the current package line:

- grouped namespace `.resi` files now use module aliases so `Mcp.*` entrypoints preserve type identity
- `McpResourceTemplate` and `Mcp.Shared.UriTemplate` bind the installed resource-template authoring surface, including typed `listCallback`
- `McpResourceTemplate.readCallback` and `Mcp.Shared.UriTemplate` now bind the installed `Variables` union as an exact scalar-or-array algebra
- `McpProtocolVersion`, `McpTypes.*ProtocolVersion`, `McpClient.getNegotiatedProtocolVersion`, and the public protocol-version option/transport surfaces now bind the installed supported-version list as a finite algebra
- `McpServer.registerResourceTemplate` and registered `update` handles are exposed
- `McpServerContext` exposes the installed high-level request APIs and HTTP fields
- `McpClient` now exposes typed protocol request/result methods for the installed prompt, resource, completion, logging-level, and tool-call surface
- `McpClient.setNotificationHandlerRaw` and `removeNotificationHandlerRaw` now bind the installed client notification-handler API
- `McpLoggingMessageParams` and `McpResourceUpdatedParams` now bind the installed notification parameter objects
- `McpSSEClientTransport` and `McpSSEClientTransportOptions` are bound
- task runtime types, task-aware option builders, experimental task entrypoints, pluggable task stores, and task queues are bound on the public ReScript surface

## Verified Boundaries

- High-level authoring:
  - `McpServer.registerTool`, `registerTool0`, `registerPrompt`, `registerPrompt0`, `registerResource`, and `registerResourceTemplate`
  - registered `update`, `update0`, `enable`, `disable`, and `remove` handles on tools, prompts, resources, and resource templates
- Typed client protocol wrappers:
  - `McpClient.ping`
  - `getNegotiatedProtocolVersion`
  - `complete`
  - `setLoggingLevel`
  - `getPrompt`
  - `listPrompts`
  - `listResources`
  - `listResourceTemplates`
  - `readResource`
  - `subscribeResource`
  - `unsubscribeResource`
  - `callTool`
  - `callToolRaw`
  - `listTools`
- Client notification handler surface:
  - `McpClient.setNotificationHandlerRaw`
  - `McpClient.removeNotificationHandlerRaw`
- Server-context request APIs:
  - `McpServerContext.requestSamplingRawWithOptions`
  - `McpServerContext.elicitInputRawWithOptions`
  - `McpServerContext.sendRelatedRequestRawWithOptions`
  - `McpServerContext.sendRelatedNotificationRaw`
  - `McpServerContext.log`
  - `McpServerContext.logWithLogger`
  - `McpServerContext.requestMethod`, `httpRequest`, and `httpAuthInfo`
- Low-level callback and notification surface:
  - `McpClient.registerCapabilities`
  - `McpClient.setRequestHandlerRaw`
  - `McpLowLevelServer.createMessageRaw`
  - `McpLowLevelServer.elicitInputRaw`
  - `McpLowLevelServer.listRoots`
  - `McpLowLevelServer.sendLoggingMessage`
  - `McpLowLevelServer.sendLoggingMessageWithSessionId`
  - `McpLowLevelServer.sendResourceUpdated`
- Protocol version control surfaces:
  - `McpProtocolVersion`
  - `McpTypes.latestProtocolVersion`
  - `McpTypes.defaultNegotiatedProtocolVersion`
  - `McpTypes.supportedProtocolVersions`
  - `McpClient.getNegotiatedProtocolVersion`
  - `McpClientOptions.make`
  - `McpServerOptions.make`
  - `McpProtocolOptions.make`
  - `McpStreamableHttpClientTransportOptions.make`
  - `McpStreamableHttpClientTransport.protocolVersion`
  - `McpStreamableHttpClientTransport.setProtocolVersion`
  - `McpSSEClientTransport.setProtocolVersion`
  - `McpWebStandardStreamableHttpServerTransportOptions.make`
  - `McpNodeStreamableHttpServerTransportOptions.make`
- Resource-template and URI-template APIs:
  - `McpResourceTemplate.make`, `makeWithUriTemplate`, `listCallback`, `completeCallback`, `readCallback`, and `uriTemplate`
  - `McpUriTemplate.make`, `variableNames`, `expand`, and `match`
- Notification parameter builders:
  - `McpLoggingMessageParams`
  - `McpResourceUpdatedParams`
- Task additions:
  - `McpTaskStatus`, `McpTask`, `McpTaskCreationParams`, `McpCreateTaskOptions`, `McpRelatedTaskMetadata`, `McpTaskManagerOptions`, `McpTaskStore`, `McpRequestTaskStore`, and `McpTaskContext`
  - `McpTaskResultStatus`
  - `McpCreateTaskResult`, `McpGetTaskResult`, `McpListTasksResult`, and `McpCancelTaskResult`
  - `McpServerContext.task`
  - `McpClient.experimentalTasks`, `McpLowLevelServer.experimentalTasks`, and `McpServer.experimentalTasks`
  - `McpTaskTool` and `McpServerExperimentalTasks.registerToolTask`
  - verified high-level runtime task wiring through `capabilities.tasks`
  - verified `TaskStore.getTask` null-classification, custom `TaskStore.make`, custom `TaskMessageQueue.make`, and low-level `requestStreamRaw` / `createMessageStreamRaw` / `elicitInputStreamRaw`

## Evidence

- `tests/ClientProtocolRoundtrip_test.res`
  - proves typed `McpClient` request/result wrappers against a live low-level loopback server
  - proves typed prompt, resource, tool, completion, logging-level, subscription, and roots roundtrips
- `tests/AuthoringLifecycleRoundtrip_test.res`
  - proves the real `McpServer` authoring surface against a live `Client`
  - proves 0-arg and schema-backed register/update paths
  - proves resource-template registration and post-registration updates
  - proves `McpServerContext` related-request APIs against live client callback handlers
  - proves `McpServerContext.sendRelatedNotificationRaw`, `log`, and `logWithLogger` through observed `notifications/message` client handlers
  - proves high-level `McpServer.sendLoggingMessage` and `sendLoggingMessageWithSessionId` through observed client notifications
- `tests/LowLevelCallbackRoundtrip_test.res`
  - proves low-level sampling, elicitation, and roots roundtrips
  - proves low-level `sendLoggingMessage*` and `sendResourceUpdated` through observed client notification handlers
- `tests/BindingObjectSurface_test.res`
  - proves option/config builders, typed `LoggingMessageParams`, typed `ResourceUpdatedParams`, grouped entrypoints, finite protocol-version builders/setters/getters, typed URI-template scalar-or-array variables, message extra info, typed resource-template `listCallback`, and registered-handle method dispatch
- `tests/ProtocolSurface_test.res`, `tests/HttpRoundtrip_test.res`, and `tests/WebStandardRequestResponse_test.res`
  - prove the public protocol-version algebra against SDK constants, live negotiated transport state, and web-standard request/response header roundtrips
- `tests/ExperimentalTasksRoundtrip_test.res`
  - proves task creation, completed result retrieval, task listing, task cancellation, task context TTL plumbing, and the public experimental task entrypoints against the live SDK
  - proves the installed high-level constructors require runtime task configuration under `capabilities.tasks`
- `tests/TaskStorageSurface_test.res`
  - proves custom `TaskStore` and `TaskMessageQueue` builders, in-memory task write methods, queue method dispatch, and the missing-task null normalization path
- `tests/ExperimentalServerTasksRoundtrip_test.res`
  - proves low-level `requestStreamRawWithOptions`, `createMessageStreamRawWithOptions`, and `elicitInputStreamRawWithOptions`
  - proves low-level `getTask`, `getTaskResultRawWithOptions`, `listTasksWithOptions`, and `cancelTaskWithOptions`
  - proves the client-side raw request handlers can create tasks through the bound request-scoped task store and complete them through the live SDK
- `tests/AuthoringRoundtrip_test.res`, `tests/StdioRoundtrip_test.res`, `tests/HttpRoundtrip_test.res`, `tests/WebStandardRequestResponse_test.res`, and `tests/PackageEntrypoints_test.res`
  - keep stdio, HTTP, web-standard, and package entrypoint surfaces live

## Direct Binding Evidence

- direct repo tests cover:
  - high-level authoring
  - ordinary typed `structuredContent`
  - typed task-result storage and retrieval reuse
  - finite protocol-version constants, setters/getters, and negotiated-version roundtrips
  - exact URI-template variables
  - typed resource-template callback variables
- compile-shape checks inside the repo must reject output-schema mismatch on the typed path

## Known Open Boundaries

- `McpLowLevelServer.setRequestHandlerRaw`, `McpClient.setRequestHandlerRaw`, and `McpClient.setNotificationHandlerRaw` remain intentionally raw.
- `McpLowLevelServer.createMessageRaw*` and `McpLowLevelServer.elicitInputRaw*` remain open at `dict<unknown>` and `promise<unknown>`.
- `McpServerContext.sendRelatedRequestRaw*`, `requestSamplingRaw*`, and `elicitInputRaw*` remain open at `dict<unknown>` and `promise<unknown>`.
- `McpCallToolParams.argumentValues`, `McpToolSchema.properties`, and protocol `_meta` dictionaries remain open caller-owned protocol payloads.
- `McpLoggingMessageParams.data` remains `unknown` because upstream logging data is explicitly open.
- `McpCallToolResult.raw`, `McpTaskStore.storeTaskResultRaw*`, `McpTaskStore.getTaskResultRaw*`, `McpRequestTaskStore.storeTaskResultRaw`, and `McpRequestTaskStore.getTaskResultRaw` remain the explicit raw heterogeneous escape hatches for non-tool task payloads.
- `McpTaskStore.createTask` keeps the original request payload open at `unknown`, and `McpTaskMessageQueue` keeps queued messages open at `unknown`, because the package still does not export the full request and JSON-RPC message unions.
- `McpTransport.send` remains open at `unknown` because the package still does not export a closed JSON-RPC message algebra.
- high-level constructor task wiring still depends on the open `capabilities` dictionary boundary because the installed runtime mixes task runtime fields into `capabilities.tasks`

## Cast And Escape Inventory

- Public raw seams are explicit and documented rather than hidden behind fake closed records.
- Public `%identity` usage remains concentrated in tests and in intentionally opaque protocol handles.
- Eleven package test files plus `tests/support/McpTestBindings.res` still rely on `%identity` and `*ToUnknown` support casts around public `unknown` seams.
- The only package-authored runtime shim in the public path remains `McpTaskStoreSupport.mjs`, which normalizes `null` from `TaskStore.getTask()` into `option`.

## Verdict

- Internal runtime-tested typed tool output, typed client result classification, typed task-result storage, finite protocol-version control, exact URI-template variable algebra, notification parameter, notification handler, transport, and experimental task surface: directly tested on the typed 99% path
- Raw low-level request/result seams, queue payloads, transport messages, and caller-owned metadata remain intentionally open and explicitly secondary
- Release-facing soundness status: the four rows in `docs/RELEASE_BLOCKERS.md` are closed on 2026-04-23
- Full upstream public line is still not complete because the raw method-indexed sampling, elicitation, related-request, JSON-RPC message, and task payload seams remain open
