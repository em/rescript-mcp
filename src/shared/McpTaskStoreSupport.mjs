export function makeTaskStore(
  createTask,
  getTask,
  storeTaskResult,
  getTaskResult,
  updateTaskStatus,
  listTasks,
) {
  return {
    createTask(taskParams, requestId, request, sessionId) {
      return createTask(taskParams, requestId, request, sessionId);
    },
    async getTask(taskId, sessionId) {
      const task = await getTask(taskId, sessionId);
      return task == null ? null : task;
    },
    storeTaskResult(taskId, status, result, sessionId) {
      return storeTaskResult(taskId, status, result, sessionId);
    },
    getTaskResult(taskId, sessionId) {
      return getTaskResult(taskId, sessionId);
    },
    updateTaskStatus(taskId, status, statusMessage, sessionId) {
      return updateTaskStatus(taskId, status, statusMessage, sessionId);
    },
    listTasks(cursor, sessionId) {
      return listTasks(cursor, sessionId);
    },
  };
}

export async function getTask(store, taskId) {
  const task = await store.getTask(taskId);
  return task == null ? undefined : task;
}

export async function getTaskWithSessionId(store, taskId, sessionId) {
  const task = await store.getTask(taskId, sessionId);
  return task == null ? undefined : task;
}
