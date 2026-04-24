// src/shared/McpProtocolOptions.res
// Concern: construct the schema-independent protocol options shared by client and server constructors.
type t

@obj
external makeRaw: (
  ~supportedProtocolVersions: array<string>=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~tasks: McpTaskManagerOptions.t=?,
  (),
) => t = ""

let make = (~supportedProtocolVersions=?, ~enforceStrictCapabilities=?, ~debouncedNotificationMethods=?, ~tasks=?, ()) => {
  let supportedProtocolVersions =
    supportedProtocolVersions->Option.map(versions => versions->Array.map(McpProtocolVersion.toString))
  makeRaw(~supportedProtocolVersions?, ~enforceStrictCapabilities?, ~debouncedNotificationMethods?, ~tasks?, ())
}
