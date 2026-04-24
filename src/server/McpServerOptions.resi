type t

let make: (
  ~capabilities: dict<unknown>=?,
  ~instructions: string=?,
  ~jsonSchemaValidator: unknown=?,
  ~supportedProtocolVersions: array<McpProtocolVersion.t>=?,
  ~enforceStrictCapabilities: bool=?,
  ~debouncedNotificationMethods: array<string>=?,
  ~tasks: McpTaskManagerOptions.t=?,
  unit,
) => t
