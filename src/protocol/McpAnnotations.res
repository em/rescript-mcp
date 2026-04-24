// src/protocol/McpAnnotations.res
// Concern: expose the closed MCP annotations object used by prompts, resources, tools, and content.
type t
type audience = [#assistant | #user]

@obj
external make: (
  ~audience: array<audience>=?,
  ~priority: float=?,
  ~lastModified: string=?,
  (),
) => t = ""

@return(nullable)
@get
external audience: t => option<array<audience>> = "audience"

@return(nullable)
@get
external priority: t => option<float> = "priority"

@return(nullable)
@get
external lastModified: t => option<string> = "lastModified"
