# Client Protocol Typed Surface Audit

## Claim

- subsystem: client protocol and notification surface
- change: typed `McpClient` request/result wrappers, typed logging/resource-updated notification params, typed `McpResourceTemplate.listCallback`, and raw client notification handlers
- boundary class:
  - result payload
  - notification params
  - raw notification handler
  - package-authored typed protocol object
- exact public surface affected:
  - `McpClient.complete`, `setLoggingLevel`, `getPrompt`, `listPrompts`, `listResources`, `listResourceTemplates`, `readResource`, `subscribeResource`, `unsubscribeResource`, `callTool`, `callToolRaw`, `listTools`, and `ping`
  - `McpClient.setNotificationHandlerRaw`
  - `McpClient.removeNotificationHandlerRaw`
  - `McpLoggingMessageParams`
  - `McpResourceUpdatedParams`
  - `McpResourceTemplate.listCallback`

## Upstream Evidence

### Declaration Evidence

- file: `node_modules/@modelcontextprotocol/server/dist/index.d.mts`
- relevant signatures:
  - `createMessage(params: CreateMessageRequest['params'], options?: RequestOptions): Promise<CreateMessageResult | CreateMessageResultWithTools>;`
  - `elicitInput(params: ElicitRequestFormParams | ElicitRequestURLParams, options?: RequestOptions): Promise<ElicitResult>;`
  - `sendLoggingMessage(params: LoggingMessageNotification['params'], sessionId?: string): Promise<void>;`
  - `sendResourceUpdated(params: ResourceUpdatedNotification['params']): Promise<void>;`
  - `get listCallback(): ListResourcesCallback | undefined;`
  - `type ListResourcesCallback = (ctx: ServerContext) => ListResourcesResult | Promise<ListResourcesResult>;`
- file: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts`
- relevant signatures:
  - `setNotificationHandler<M extends NotificationMethod>(method: M, handler: (notification: NotificationTypeMap[M]) => void | Promise<void>): void;`
  - `removeNotificationHandler(method: NotificationMethod): void;`
  - type aliases for `ListResourcesResult`, `ListResourceTemplatesResult`, `ListPromptsResult`, `GetPromptResult`, `CallToolResult`, `CompleteResult`, `LoggingMessageNotificationParams`, and `ResourceUpdatedNotificationParams`

### Runtime Evidence

- command or probe:
  - `tests/ClientProtocolRoundtrip_test.res`
  - `tests/AuthoringLifecycleRoundtrip_test.res`
  - `tests/LowLevelCallbackRoundtrip_test.res`
- result:
  - typed client wrappers dispatch to live SDK methods and return the expected typed result objects
  - raw client notification handlers observe live `notifications/message` and `notifications/resources/updated` notifications
  - typed `McpResourceTemplate.listCallback` returns `McpListResourcesResult.t` through the public callback getter

## Local Representation

- affected files:
  - `src/client/McpClient.resi`
  - `src/protocol/McpCompleteParams.resi`
  - `src/protocol/McpCompleteResult.resi`
  - `src/protocol/McpGetPromptParams.resi`
  - `src/protocol/McpListPromptsResult.resi`
  - `src/protocol/McpListResourcesResult.resi`
  - `src/protocol/McpListResourceTemplatesResult.resi`
  - `src/protocol/McpResourceRequestParams.resi`
  - `src/protocol/McpCallToolParams.resi`
  - `src/protocol/McpListToolsResult.resi`
  - `src/protocol/McpLoggingMessageParams.resi`
  - `src/protocol/McpResourceUpdatedParams.resi`
  - `src/server/McpServer.resi`
  - `src/server/McpLowLevelServer.resi`
  - `src/server/McpResourceTemplate.resi`
- chosen ReScript shape:
  - method-specific protocol objects are separate opaque modules with exact outer fields
  - caller-owned subfields stay open where upstream still uses `unknown`
  - notification handling is exposed as an explicit raw seam instead of a fake closed notification union

## Alternatives Considered

### Alternative 1

- representation: keep the whole client request/result surface at `dict<unknown>` and `promise<unknown>`
- why rejected: the installed SDK exports materially narrower result types for these methods, and the broad `unknown` surface was stale and misleading

### Alternative 2

- representation: invent fully closed ReScript records for tool arguments, structured tool results, log payloads, and metadata dictionaries
- why rejected: those nested payloads remain caller-owned or protocol-open in the installed SDK and cannot be truthfully closed without a separate JSON value algebra

## Adversarial Questions

- question: did the binding only add constructors without proving the methods call the right SDK entrypoints?
- evidence-based answer: `tests/ClientProtocolRoundtrip_test.res` runs each wrapper against a live low-level server and verifies the returned typed objects, and the generated JS delegates directly to the SDK methods in `src/client/McpClient.mjs`.

- question: is `McpResourceTemplate.listCallback` still pretending to be typed while the runtime remains open?
- evidence-based answer: the installed declaration line defines `ListResourcesCallback` as returning `ListResourcesResult`, the public `.resi` now matches that signature, and `tests/BindingObjectSurface_test.res` invokes the callback through the getter and reads a typed `McpListResourcesResult.t`.

- question: did notification coverage only assert that calls do not throw?
- evidence-based answer: `tests/AuthoringLifecycleRoundtrip_test.res` and `tests/LowLevelCallbackRoundtrip_test.res` register public raw notification handlers and assert the received notification data.

## Failure Modes Targeted

- failure mode: a wrapper calls the wrong runtime method or wrong arity
- how the current design prevents or exposes it: generated JS delegates one-for-one to the SDK method names
- test or probe covering it: `tests/ClientProtocolRoundtrip_test.res`

- failure mode: the package claims a typed notification parameter object but actually ships an open dictionary
- how the current design prevents or exposes it: notification params are dedicated modules with typed accessors and runtime dispatch coverage
- test or probe covering it: `tests/BindingObjectSurface_test.res`, `tests/AuthoringLifecycleRoundtrip_test.res`, `tests/LowLevelCallbackRoundtrip_test.res`

- failure mode: raw notifications are emitted but the public client binding cannot observe them
- how the current design prevents or exposes it: the raw client notification handler is bound and observed through live loopback transports
- test or probe covering it: `tests/AuthoringLifecycleRoundtrip_test.res`, `tests/LowLevelCallbackRoundtrip_test.res`

## Evidence

### Build

- command: `npm run build`
- result: passes on 2026-04-23

### Tests

- command: `npm test`
- result: passes with 15 files and 20 tests on 2026-04-23

### Emitted JS Inspection

- file or command:
  - `src/client/McpClient.mjs`
  - `src/server/McpLowLevelServer.mjs`
  - `src/server/McpResourceTemplate.mjs`
- result:
  - `setNotificationHandlerRaw` delegates to `prim0.setNotificationHandler(...)`
  - `removeNotificationHandlerRaw` delegates to `prim0.removeNotificationHandler(...)`
  - `sendLoggingMessageWithSessionId` delegates to `prim0.sendLoggingMessage(...)`
  - `sendResourceUpdated` delegates to `prim0.sendResourceUpdated(...)`
  - `listCallback` reads `prim.listCallback` through nullable classification

### Soundness Matrix Update

- affected row:
  - `Client Protocol`
  - `Client Notifications`
  - `Server Context`
  - `Low-level Server`
  - `Resource Templates`
- update made: replaced the stale open-client row, removed the weak raw-notification gap row, and attached direct runtime tests for live notification observation

## Residual Risk

- remaining open boundary: tool-enabled sampling, sampling-message `tool_use` / `tool_result` blocks, method-indexed related requests, JSON-RPC message, and task-result payload seams
- why it remains open: the installed SDK still exposes those surfaces as overloads, method-indexed maps, or payload mirrors that this package has not yet exported as dedicated ReScript modules
- where it is documented:
  - `docs/TYPE_FIDELITY.md`
  - `docs/TYPE_SOUNDNESS_AUDIT.md`
  - `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-23
