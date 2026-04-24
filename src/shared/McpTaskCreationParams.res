// src/shared/McpTaskCreationParams.res
// Concern: construct task augmentation params for outbound request options.
type t

@obj
external make: (
  ~ttl: int=?,
  ~pollInterval: int=?,
  (),
) => t = ""
