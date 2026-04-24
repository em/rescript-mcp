type t

let make: (
  ~onprogress: (unknown => unit)=?,
  ~signal: unknown=?,
  ~timeout: int=?,
  ~resetTimeoutOnProgress: bool=?,
  ~maxTotalTimeout: int=?,
  ~task: McpTaskCreationParams.t=?,
  ~relatedTask: McpRelatedTaskMetadata.t=?,
  ~relatedRequestId: unknown=?,
  ~resumptionToken: string=?,
  ~onresumptiontoken: (string => unit)=?,
  unit,
) => t
