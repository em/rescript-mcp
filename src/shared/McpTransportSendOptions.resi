type t

let make: (
  ~relatedRequestId: unknown=?,
  ~resumptionToken: string=?,
  ~onresumptiontoken: (string => unit)=?,
  unit,
) => t
