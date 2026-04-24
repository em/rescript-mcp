export function makeTaskMessageQueue(enqueue, dequeue, dequeueAll) {
  return {
    enqueue(taskId, message, sessionId, maxSize) {
      return enqueue(taskId, message, sessionId, maxSize);
    },
    dequeue(taskId, sessionId) {
      return dequeue(taskId, sessionId);
    },
    dequeueAll(taskId, sessionId) {
      return dequeueAll(taskId, sessionId);
    },
  };
}
