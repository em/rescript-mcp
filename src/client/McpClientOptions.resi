type t

let make: (
  ~capabilities: dict<unknown>=?,
  ~jsonSchemaValidator: unknown=?,
  ~listChanged: unknown=?,
  ~supportedProtocolVersions: array<McpProtocolVersion.t>=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~tasks: McpTaskManagerOptions.t=?,
  unit,
) => t
