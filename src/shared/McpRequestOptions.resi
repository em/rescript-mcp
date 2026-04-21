type t

let make: (
  ~onprogress: (unknown => unit)=?,
  ~signal: unknown=?,
  ~timeout: int=?,
  ~resetTimeoutOnProgress: bool=?,
  ~maxTotalTimeout: int=?,
  ~task: dict<unknown>=?,
  ~relatedTask: dict<unknown>=?,
  ~relatedRequestId: unknown=?,
  ~resumptionToken: string=?,
  ~onresumptiontoken: (string => unit)=?,
  unit,
) => t
