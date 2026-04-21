type t

let make: (
  ~command: string,
  ~args: array<string>=?,
  ~env: dict<string>=?,
  ~stderr: unknown=?,
  ~cwd: string=?,
) => t
