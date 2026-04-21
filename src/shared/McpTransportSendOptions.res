// src/shared/McpTransportSendOptions.res
// Concern: construct the shared transport send options object.
type t

@obj
external make: (
  ~relatedRequestId: unknown=?,
  ~resumptionToken: string=?,
  ~onresumptiontoken: (string => unit)=?,
  (),
) => t = ""
