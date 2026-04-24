type t<'output>
type raw

let make: (
  ~content: array<McpContentBlock.t>,
  ~structuredContent: 'output=?,
  ~isError: bool=?,
  (),
) => t<'output>
let makeRaw: (
  ~content: array<McpContentBlock.t>,
  ~structuredContent: dict<McpJsonValue.t>=?,
  ~isError: bool=?,
  (),
) => raw
let content: t<'output> => array<McpContentBlock.t>
let structuredContent: t<'output> => option<'output>
let isError: t<'output> => option<bool>
let contentRaw: raw => array<McpContentBlock.t>
let structuredContentRaw: raw => option<dict<McpJsonValue.t>>
let isErrorRaw: raw => option<bool>
