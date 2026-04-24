# Sampling And Elicitation Typed Surface Audit

## Claim

- subsystem: low-level server and server-context sampling and elicitation surface
- change: typed ordinary sampling requests/results and typed elicitation request envelopes on the public path
- boundary class:
  - request payload
  - result payload
  - schema seam
- exact public surface affected:
  - `McpCreateMessageParams`
  - `McpCreateMessageResult`
  - `McpModelPreferences`
  - `McpSamplingContent`
  - `McpSamplingMessage`
  - `McpElicitRequestFormParams`
  - `McpElicitRequestUrlParams`
  - `McpElicitResult`
  - `McpLowLevelServer.createMessage*`
  - `McpLowLevelServer.elicitFormInput*`
  - `McpLowLevelServer.elicitUrlInput*`
  - `McpServerContext.requestSampling*`
  - `McpServerContext.elicitFormInput*`
  - `McpServerContext.elicitUrlInput*`

## Upstream Evidence

### Declaration Evidence

- file: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts`
- relevant signatures:
  - `type ModelPreferences = Infer<typeof ModelPreferencesSchema>;`
  - `type SamplingContent = Infer<typeof SamplingContentSchema>;`
  - `type SamplingMessage = Infer<typeof SamplingMessageSchema>;`
  - `type CreateMessageRequestParams = Infer<typeof CreateMessageRequestParamsSchema>;`
  - `type CreateMessageResult = Infer<typeof CreateMessageResultSchema>;`
  - `type CreateMessageResultWithTools = Infer<typeof CreateMessageResultWithToolsSchema>;`
  - `type ElicitRequestFormParams = Infer<typeof ElicitRequestFormParamsSchema>;`
  - `type ElicitRequestURLParams = Infer<typeof ElicitRequestURLParamsSchema>;`
  - `type ElicitResult = Infer<typeof ElicitResultSchema>;`
- file: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`
- relevant signatures:
  - `createMessage(params: CreateMessageRequest['params'], options?: RequestOptions): Promise<CreateMessageResult | CreateMessageResultWithTools>;`
  - `elicitInput(params: ElicitRequestFormParams | ElicitRequestURLParams, options?: RequestOptions): Promise<ElicitResult>;`
  - `requestSampling(params: CreateMessageRequest['params'], options?: RequestOptions): Promise<CreateMessageResult | CreateMessageResultWithTools>;`
  - `elicitInput(params: ElicitRequestFormParams | ElicitRequestURLParams, options?: RequestOptions): Promise<ElicitResult>;`

### Runtime Evidence

- command or probe:
  - `tests/LowLevelCallbackRoundtrip_test.res`
  - `tests/AuthoringLifecycleRoundtrip_test.res`
  - `tests/PublicWrapperCoverage_test.res`
- result:
  - live loopback client callbacks satisfy typed no-tools sampling requests and typed form elicitation requests
  - high-level authoring handlers call `McpServerContext.requestSampling*` and `elicitFormInput*` successfully against a live client
  - direct wrapper fixtures prove typed and raw low-level/context dispatch through the installed method names

## Local Representation

- affected files:
  - `src/protocol/McpCreateMessageParams.resi`
  - `src/protocol/McpCreateMessageResult.resi`
  - `src/protocol/McpModelPreferences.resi`
  - `src/protocol/McpSamplingContent.resi`
  - `src/protocol/McpSamplingMessage.resi`
  - `src/protocol/McpElicitRequestFormParams.resi`
  - `src/protocol/McpElicitRequestUrlParams.resi`
  - `src/protocol/McpElicitResult.resi`
  - `src/server/McpLowLevelServer.resi`
  - `src/server/McpServerContext.resi`
- chosen ReScript shape:
  - ordinary no-tools sampling request/result objects are dedicated typed modules
  - typed sampling messages intentionally cover the ordinary text-image-audio subset
  - typed elicitation covers the installed form and url request envelopes
  - `McpElicitRequestFormParams.requestedSchema` and `McpElicitResult.content` stay explicit schema seams at `dict<unknown>`
  - tool-enabled sampling requests/results and sampling-message `tool_use` / `tool_result` blocks remain on the raw surface

## Alternatives Considered

### Alternative 1

- representation: keep sampling and elicitation entirely raw
- why rejected: the installed SDK exports materially narrower ordinary request/result objects, and the binding can expose that ordinary path truthfully without weakening the whole surface

### Alternative 2

- representation: claim the full installed sampling-message union is already typed by reusing `McpContentBlock`
- why rejected: the installed `SamplingMessage` union includes `tool_use` and `tool_result` blocks that are not the same surface as prompt/tool-result `ContentBlock`

## Failure Modes Targeted

- failure mode: typed low-level wrappers call the right method name but classify the wrong request/result shape
- how the current design prevents or exposes it: live loopback tests exercise `createMessage`, `requestSampling`, and `elicitInput` through the installed runtime and read the typed accessors
- test or probe covering it: `tests/LowLevelCallbackRoundtrip_test.res`, `tests/AuthoringLifecycleRoundtrip_test.res`

- failure mode: wrapper builders exist but public field accessors or enum classification drift from the installed payloads
- how the current design prevents or exposes it: direct wrapper coverage constructs and reads every new builder/accessor pair
- test or probe covering it: `tests/PublicWrapperCoverage_test.res`

- failure mode: the typed path silently widens the whole surface instead of isolating the wider overload remainder
- how the current design prevents or exposes it: the public typed path is limited to the ordinary no-tools request/result modules, and the raw methods remain explicit for the wider overload
- test or probe covering it: `docs/TYPE_FIDELITY.md`, `tests/PublicWrapperCoverage_test.res`

## Evidence

### Build

- command: `npm run build`
- result: passes on 2026-04-24

### Tests

- command: `npm test`
- result: passes with 17 files and 30 tests on 2026-04-24

### Package Shape

- command: `npm pack --dry-run`
- result: passes on 2026-04-24

## Residual Risk

- remaining open boundary: tool-enabled sampling requests/results, sampling-message `tool_use` / `tool_result` blocks, method-indexed related requests, and JSON-RPC message payloads
- why it remains open: those installed surfaces still require additional dedicated ReScript modules to model the wider overload algebra truthfully
- where it is documented:
  - `docs/TYPE_FIDELITY.md`
  - `docs/TYPE_SOUNDNESS_AUDIT.md`
  - `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status:
  - acceptable with documented typed-subset boundary
- reviewer: Codex
- date: 2026-04-24
