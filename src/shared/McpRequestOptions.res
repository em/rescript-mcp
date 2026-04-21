// src/shared/McpRequestOptions.res
// Concern: construct per-request options used by client connect and request methods.
type t

@obj
external make: (
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
  (),
) => t = ""
