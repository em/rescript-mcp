type t

let make: (
  ~supportedProtocolVersions: array<McpProtocolVersion.t>=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~tasks: McpTaskManagerOptions.t=?,
  unit,
) => t
