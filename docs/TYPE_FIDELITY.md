# Type Fidelity

## Purpose

This file records the deliberate gaps between upstream MCP TypeScript expressivity and the current public ReScript surface.

The public `.resi` files stay authoritative. This file explains where the binding is intentionally narrower, more open, or package-added.

## Fidelity Gaps

### Capability objects and metadata dictionaries

- Public surface:
  - `McpServerOptions.make`
  - `McpClientOptions.make`
  - `McpProtocolOptions.make`
  - `McpTool.makeConfig`
  - `McpPrompt.makeConfig`
  - `McpResource.makeConfig`
  - `McpAuthInfo.make`
- ReScript representation: `dict<unknown>` for capabilities, annotations, `_meta`, task metadata, and extra metadata.
- Why: these are broad structural objects with caller-owned fields and evolving nested branches. The package keeps the boundary honest instead of inventing stale closed records.

### High-level task runtime configuration

- Public surface:
  - `McpServerOptions.make`
  - `McpClientOptions.make`
  - `McpTaskManagerOptions.make`
  - `McpTaskStore.make`
  - `McpTaskStore.makeInMemory`
  - `McpTaskMessageQueue.make`
  - `McpTaskMessageQueue.makeInMemory`
- ReScript representation:
  - high-level constructor `capabilities` remains `dict<unknown>`
  - task runtime modules are typed, but they currently flow into high-level constructors through `capabilities.tasks`
- Why: the installed high-level `McpServer` and `Client` constructors extract task runtime from `options.capabilities.tasks` at runtime, even though their declaration line also inherits top-level `ProtocolOptions.tasks`. The binding keeps the runtime path honest and documents that the typed task modules currently meet the high-level API through the open capabilities boundary.

### Task-store requests and queued task messages

- Public surface:
  - `McpTaskStore.make`
  - `McpTaskStore.createTask`
  - `McpTaskMessageQueue.make`
  - `McpTaskMessageQueue.enqueue`
  - `McpTaskMessageQueue.dequeue`
  - `McpTaskMessageQueue.dequeueAll`
- ReScript representation:
  - original stored request payload: `unknown`
  - queued task messages: `unknown`
- Why: upstream `TaskStore.createTask` persists the original protocol request, and `TaskMessageQueue` transports queued JSON-RPC messages. The package keeps the full request and message unions open rather than inventing fake closed records for those protocol seams.
- Current consequence:
  - direct public-surface tests can store typed tool results through `McpTaskStore.storeTaskResult`
  - queued JSON-RPC task messages still require the explicit raw queue boundary

### Tool output schemas and structured content

- Public surface:
  - `McpTool.config<'input, 'output>`
  - `McpTaskTool.config<'input, 'output>`
  - `McpServer.registerTool`
  - `McpServerExperimentalTasks.registerToolTask`
  - `McpCallToolResult.make`
- ReScript representation:
  - input schema drives the handler argument type
  - typed config requires `outputSchema`
  - typed handlers return `McpCallToolResult.t<'output>`
  - typed `structuredContent` is ordinary ReScript `'output`
  - explicit raw escape hatches are separate:
    - `McpCallToolResult.raw`
    - `McpServer.registerToolRaw*`
    - `McpServerExperimentalTasks.registerToolTaskRaw*`
- Why: the package now uses the installed Standard Schema bridge to serialize and classify typed structured tool output on the typed 99% path, while keeping heterogeneous raw payloads explicit.
- Current consequence:
  - mismatched typed output fails to compile through repo-owned type-shape checks
  - low-level raw tool results still require the explicit raw path

### Raw low-level request and notification handlers

- Public surface:
  - `McpLowLevelServer.setRequestHandlerRaw`
  - `McpClient.setRequestHandlerRaw`
  - `McpClient.setNotificationHandlerRaw`
- ReScript representation:
  - method names stay raw
  - request and notification payloads stay `unknown`
  - raw handler results stay `promise<unknown>` or `promise<unit>`
- Why: the installed protocol objects are method-indexed. The package exposes explicit raw seams instead of claiming per-method precision it has not exported yet.

### Protocol version control surfaces

- Public surface:
  - `McpProtocolVersion.t`
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
- ReScript representation:
  - finite `McpProtocolVersion.t` variant on the public control path
- Why: the installed SDK line publishes a finite supported-version list and exposes protocol-version control points that should stay aligned with that list instead of widening back to raw strings.
- Current consequence:
  - public option builders, transport setters/getters, constants, and negotiated-version access all stay on the same finite algebra
  - if a runtime value falls outside the installed supported list, classification throws immediately and the binding must be widened through an audited SDK-line update

### Sampling, elicitation, and related-request APIs

- Public surface:
  - `McpLowLevelServer.createMessageRaw`
  - `McpLowLevelServer.createMessageRawWithOptions`
  - `McpLowLevelServer.elicitInputRaw`
  - `McpLowLevelServer.elicitInputRawWithOptions`
  - `McpServerContext.requestSamplingRaw`
  - `McpServerContext.requestSamplingRawWithOptions`
  - `McpServerContext.elicitInputRaw`
  - `McpServerContext.elicitInputRawWithOptions`
  - `McpServerContext.sendRelatedRequestRaw`
  - `McpServerContext.sendRelatedRequestRawWithOptions`
  - `McpServerContext.sendRelatedNotificationRaw`
- ReScript representation:
  - params payloads: `dict<unknown>`
  - result payloads: `promise<unknown>`
  - related request methods remain plain `string`
- Why: the installed SDK still models these surfaces through overloads or method-indexed request maps. The binding keeps those dynamic seams explicit until the full request/result algebra is exported as dedicated ReScript modules.

### Request-scoped and stored task results

- Public surface:
  - `McpRequestTaskStore.storeTaskResult`
  - `McpRequestTaskStore.getTaskResult`
  - `McpTaskStore.storeTaskResult`
  - `McpTaskStore.getTaskResult`
  - `McpClientExperimentalTasks.getTaskResultRaw`
  - `McpLowLevelServerExperimentalTasks.getTaskResultRaw`
- ReScript representation:
  - typed tool-result storage and retrieval use `McpCallToolResult.t<'output>` plus `McpStandardSchema.t<'output>`
  - raw heterogeneous storage and retrieval remain explicit through `storeTaskResultRaw*` and `getTaskResultRaw*`
- Why: tool-task results now have a truthful typed 99% path, while non-tool task payloads still mirror the originating request result type and therefore stay raw.
- Current consequence:
  - typed tool-result storage and retrieval no longer require a consumer-authored adapter
  - heterogeneous non-tool task payloads still use the explicit raw path

### Typed client and notification protocol objects with open caller payloads

- Public surface:
  - typed `McpClient` request/result methods such as `complete`, `getPrompt`, `listPrompts`, `listResources`, `listResourceTemplates`, `readResource`, `subscribeResource`, `unsubscribeResource`, `callTool`, and `listTools`
  - `McpResourceTemplate.listCallback`
  - `McpLoggingMessageParams`
  - `McpResourceUpdatedParams`
- ReScript representation:
  - method-specific outer request/result objects are dedicated typed modules
  - caller-owned or schema-owned subfields remain open:
    - `McpCallToolParams.argumentValues: dict<unknown>`
    - `_meta` dictionaries on request/result objects
    - `McpLoggingMessageParams.data: unknown`
- Why: the installed declarations fix the outer protocol shape, but tool arguments, structured tool results, metadata, and log payloads remain caller-defined or protocol-open.

### Client result-schema bridge

- Public surface:
  - `McpClient.callTool`
  - `McpClient.callToolRaw`
- ReScript representation:
  - `callTool` is the public typed result-schema bridge
  - `callToolRaw` remains the explicit raw escape hatch
- Why: the typed client path now classifies raw SDK tool results through `McpStandardSchema.t<'output>` instead of forcing consumers to drop to an internal adapter.

### Tool schema properties

- Public surface:
  - `McpToolSchema.make`
  - `McpToolSchema.properties`
- ReScript representation: `dict<unknown>`
- Why: upstream tool schemas ultimately admit open JSON values. The package has not yet exported a full JSON value or JSON Schema algebra, so it keeps the nested schema-property map open instead of inventing fake precision.

### Transport send boundary

- Upstream declaration anchor: installed server declarations define `Transport.send(message: JSONRPCMessage, options?: TransportSendOptions): Promise<void>`
- Public surface:
  - `McpTransport.send`
  - `McpTransport.sendWithOptions`
- ReScript representation: `unknown` message payload
- Why: the package still transports JSON-RPC messages opaquely instead of exporting a closed protocol message algebra.

### Protocol message and request-id handles

- Public surface:
  - `McpTypes.jsonRpcMessage`
  - `McpTypes.requestId`
- ReScript representation: opaque types
- Why: the package exposes protocol constants and broad handles without yet exporting structural decoders or constructors for the full JSON-RPC message union.

### Standard Schema bridge

- Public surface: `McpStandardSchema.t<'output>`
- ReScript representation: package-owned Standard Schema bridge built from `rescript-schema`
- Why: the current package line already exposes high-level authoring APIs and uses a package-owned bridge rather than forcing raw schema values through high-level config. The bridge is package-authored surface and must stay explicitly tested and documented.

### SSE and HTTP transport hooks

- Public surface:
  - `McpSSEClientTransportOptions.make`
  - `McpStreamableHttpClientTransportOptions.make`
  - `McpWebStandardStreamableHttpServerTransportOptions.make`
  - `McpNodeStreamableHttpServerTransportOptions.make`
- ReScript representation:
  - auth providers, custom fetch hooks, event stores, reconnection schedulers, and event-source init remain `unknown`
- Why: those hooks are caller-owned runtime objects or callback protocols that are broader than the package’s current typed wrapper surface. The binding keeps them open instead of claiming closed ReScript records that the upstream SDK does not guarantee.
