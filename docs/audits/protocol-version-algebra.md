# Protocol Version Algebra Audit

## Claim

- subsystem: protocol-version control surface
- change: public protocol-version constants, negotiated-version access, option builders, and transport setters/getters now use a finite algebra instead of raw strings
- boundary class:
  - exact binding
  - runtime classification
  - package-authored algebraic representation

## Upstream Evidence

### Declaration Evidence

- file: `node_modules/@modelcontextprotocol/client/dist/index.d.mts`
- relevant signatures:
  - `getNegotiatedProtocolVersion(): string | undefined;`
  - `protocolVersion?: string;`
  - `setProtocolVersion(version: string): void;`
  - `supportedProtocolVersions?: string[];`
- file: `node_modules/@modelcontextprotocol/server/dist/index.d.mts`
- relevant signatures:
  - `supportedProtocolVersions?: string[];`
- files:
  - `node_modules/@modelcontextprotocol/server/dist/index.d.mts`
  - `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`
  - `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts`
- relevant constants:
  - `LATEST_PROTOCOL_VERSION`
  - `DEFAULT_NEGOTIATED_PROTOCOL_VERSION`
  - `SUPPORTED_PROTOCOL_VERSIONS`

### Installed Supported List

The installed SDK line exposes this finite list:

- `2025-11-25`
- `2025-06-18`
- `2025-03-26`
- `2024-11-05`
- `2024-10-07`

## Local Representation

- `src/core/McpProtocolVersion.resi`
  - `type t = [#v2024_10_07 | #v2024_11_05 | #v2025_03_26 | #v2025_06_18 | #v2025_11_25]`
- public control surfaces classify to that finite algebra:
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

## Alternatives Considered

### Alternative 1

- representation: keep every public protocol-version surface at `string`
- why rejected: the installed SDK line publishes a finite supported list, and the public control surfaces should stay aligned with that list

### Alternative 2

- representation: tighten only the constants but leave builders and transport setters/getters at `string`
- why rejected: that would let the public path disagree with itself and would preserve the same stringly-typed drift at the call sites that matter

## Failure Modes Targeted

- failure mode: one public control surface widens back to `string` while the others stay finite
- tests covering it:
  - `tests/ProtocolSurface_test.res`
  - `tests/BindingObjectSurface_test.res`

- failure mode: live negotiated protocol state is still exposed as `string`
- tests covering it:
  - `tests/HttpRoundtrip_test.res`
  - `tests/WebStandardRequestResponse_test.res`

- failure mode: builder inputs accept values outside the installed supported list
- tests covering it:
  - `tests/BindingObjectSurface_test.res`

## Residual Risk

Classification currently throws if the runtime reports a protocol version outside the installed supported list.

That is intentional for this SDK line. A future SDK-line update that changes the supported set must widen `McpProtocolVersion.t` and the attached tests together.
