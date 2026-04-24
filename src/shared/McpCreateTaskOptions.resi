type t

let make: (
  ~ttl: int=?,
  ~pollInterval: int=?,
  ~context: dict<unknown>=?,
  unit,
) => t
