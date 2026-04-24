// src/protocol/McpIcon.res
// Concern: expose the shared icon object used by prompt, resource, resource-template, and tool descriptors.
type t
type theme = [#dark | #light]

@obj
external make: (
  ~src: string,
  ~mimeType: string=?,
  ~sizes: array<string>=?,
  ~theme: theme=?,
  (),
) => t = ""

@get
external src: t => string = "src"

@return(nullable)
@get
external mimeType: t => option<string> = "mimeType"

@return(nullable)
@get
external sizes: t => option<array<string>> = "sizes"

@return(nullable)
@get
external theme: t => option<theme> = "theme"
