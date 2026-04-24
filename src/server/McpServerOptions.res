// src/server/McpServerOptions.res
// Concern: construct low-level and high-level server options.
type t

@obj
external makeRaw: (
  ~capabilities: dict<unknown>=?,
  ~instructions: string=?,
  ~jsonSchemaValidator: unknown=?,
  ~supportedProtocolVersions: array<string>=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~tasks: McpTaskManagerOptions.t=?,
  (),
) => t = ""

let make = (~capabilities=?, ~instructions=?, ~jsonSchemaValidator=?, ~supportedProtocolVersions=?, ~enforceStrictCapabilities=?, ~debouncedNotificationMethods=?, ~tasks=?, ()) => {
  let supportedProtocolVersions =
    supportedProtocolVersions->Option.map(versions => versions->Array.map(McpProtocolVersion.toString))
  makeRaw(~capabilities?, ~instructions?, ~jsonSchemaValidator?, ~supportedProtocolVersions?, ~enforceStrictCapabilities?, ~debouncedNotificationMethods?, ~tasks?, ())
}
