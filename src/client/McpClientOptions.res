// src/client/McpClientOptions.res
// Concern: construct high-level client options.
type t

@obj
external makeRaw: (
  ~capabilities: dict<unknown>=?,
  ~jsonSchemaValidator: unknown=?,
  ~listChanged: unknown=?,
  ~supportedProtocolVersions: array<string>=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~tasks: McpTaskManagerOptions.t=?,
  (),
) => t = ""

let make = (~capabilities=?, ~jsonSchemaValidator=?, ~listChanged=?, ~supportedProtocolVersions=?, ~enforceStrictCapabilities=?, ~debouncedNotificationMethods=?, ~tasks=?, ()) => {
  let supportedProtocolVersions =
    supportedProtocolVersions->Option.map(versions => versions->Array.map(McpProtocolVersion.toString))
  makeRaw(~capabilities?, ~jsonSchemaValidator?, ~listChanged?, ~supportedProtocolVersions?, ~enforceStrictCapabilities?, ~debouncedNotificationMethods?, ~tasks?, ())
}
