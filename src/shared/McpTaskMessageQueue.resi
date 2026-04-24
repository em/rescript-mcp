type t

let make: (
  ~enqueue: @uncurry (string, unknown, option<string>, option<int>) => promise<unit>,
  ~dequeue: @uncurry (string, option<string>) => promise<option<unknown>>,
  ~dequeueAll: @uncurry (string, option<string>) => promise<array<unknown>>,
  unit,
) => t
let makeInMemory: unit => t
let enqueue: (t, string, unknown, ~sessionId: string=?, ~maxSize: int=?, unit) => promise<unit>
let dequeue: (t, string, ~sessionId: string=?, unit) => promise<option<unknown>>
let dequeueAll: (t, string, ~sessionId: string=?, unit) => promise<array<unknown>>
