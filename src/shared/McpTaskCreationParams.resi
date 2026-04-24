type t

let make: (
  ~ttl: int=?,
  ~pollInterval: int=?,
  unit,
) => t
