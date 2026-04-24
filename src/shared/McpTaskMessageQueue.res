// src/shared/McpTaskMessageQueue.res
// Concern: bind the public task message queue objects, including pluggable custom queue implementations.
// Source: @modelcontextprotocol/{client,server} TaskMessageQueue and InMemoryTaskMessageQueue
// Boundary: queued message payloads stay open at `unknown` because the package does not yet export the full JSON-RPC message algebra.
// Why this shape: upstream queue methods are stable and public, but queued messages carry protocol-union payloads.
// Coverage: tests/TaskStorageSurface_test.res
type t

@module("./McpTaskMessageQueueSupport.mjs")
external make: (
  ~enqueue: @uncurry (string, unknown, option<string>, option<int>) => promise<unit>,
  ~dequeue: @uncurry (string, option<string>) => promise<option<unknown>>,
  ~dequeueAll: @uncurry (string, option<string>) => promise<array<unknown>>,
  (),
) => t = "makeTaskMessageQueue"

@module("@modelcontextprotocol/server")
@new
external makeInMemory: unit => t = "InMemoryTaskMessageQueue"

@send
external enqueueRaw: (t, string, unknown, option<string>, option<int>) => promise<unit> = "enqueue"

let enqueue = (queue, taskId, message, ~sessionId=?, ~maxSize=?, ()) =>
  queue->enqueueRaw(taskId, message, sessionId, maxSize)

@send
external dequeueRaw: (t, string, option<string>) => promise<option<unknown>> = "dequeue"

let dequeue = (queue, taskId, ~sessionId=?, ()) => queue->dequeueRaw(taskId, sessionId)

@send
external dequeueAllRaw: (t, string, option<string>) => promise<array<unknown>> = "dequeueAll"

let dequeueAll = (queue, taskId, ~sessionId=?, ()) => queue->dequeueAllRaw(taskId, sessionId)
