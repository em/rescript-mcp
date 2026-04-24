// src/protocol/McpMethod.res
// Concern: classify the finite MCP request and notification method literals on the public binding surface.
// Source: `node_modules/@modelcontextprotocol/client/dist/index-C0W4X3eT.d.mts`.
// What was learned: the installed SDK exports a finite `RequestMethod` and `NotificationMethod` union rather than open method-name strings.
// Coverage: tests/ClientProtocolRoundtrip_test.res, tests/LowLevelCallbackRoundtrip_test.res, tests/AuthoringLifecycleRoundtrip_test.res
type request = [
  | #completionComplete
  | #loggingSetLevel
  | #promptsGet
  | #promptsList
  | #resourcesList
  | #resourcesTemplatesList
  | #resourcesRead
  | #resourcesSubscribe
  | #resourcesUnsubscribe
  | #toolsCall
  | #toolsList
  | #samplingCreateMessage
  | #elicitationCreate
  | #rootsList
  | #tasksGet
  | #tasksResult
  | #tasksList
  | #tasksCancel
  | #ping
]

type notification = [
  | #cancelled
  | #progress
  | #initialized
  | #rootsListChanged
  | #tasksStatus
  | #message
  | #resourcesUpdated
  | #resourcesListChanged
  | #toolsListChanged
  | #promptsListChanged
  | #elicitationComplete
]

let requestToString = method_ =>
  switch method_ {
  | #completionComplete => "completion/complete"
  | #loggingSetLevel => "logging/setLevel"
  | #promptsGet => "prompts/get"
  | #promptsList => "prompts/list"
  | #resourcesList => "resources/list"
  | #resourcesTemplatesList => "resources/templates/list"
  | #resourcesRead => "resources/read"
  | #resourcesSubscribe => "resources/subscribe"
  | #resourcesUnsubscribe => "resources/unsubscribe"
  | #toolsCall => "tools/call"
  | #toolsList => "tools/list"
  | #samplingCreateMessage => "sampling/createMessage"
  | #elicitationCreate => "elicitation/create"
  | #rootsList => "roots/list"
  | #tasksGet => "tasks/get"
  | #tasksResult => "tasks/result"
  | #tasksList => "tasks/list"
  | #tasksCancel => "tasks/cancel"
  | #ping => "ping"
  }

let requestFromString = value =>
  switch value {
  | "completion/complete" => #completionComplete
  | "logging/setLevel" => #loggingSetLevel
  | "prompts/get" => #promptsGet
  | "prompts/list" => #promptsList
  | "resources/list" => #resourcesList
  | "resources/templates/list" => #resourcesTemplatesList
  | "resources/read" => #resourcesRead
  | "resources/subscribe" => #resourcesSubscribe
  | "resources/unsubscribe" => #resourcesUnsubscribe
  | "tools/call" => #toolsCall
  | "tools/list" => #toolsList
  | "sampling/createMessage" => #samplingCreateMessage
  | "elicitation/create" => #elicitationCreate
  | "roots/list" => #rootsList
  | "tasks/get" => #tasksGet
  | "tasks/result" => #tasksResult
  | "tasks/list" => #tasksList
  | "tasks/cancel" => #tasksCancel
  | "ping" => #ping
  | other => JsError.throwWithMessage("Unsupported MCP request method: " ++ other)
  }

let notificationToString = method_ =>
  switch method_ {
  | #cancelled => "notifications/cancelled"
  | #progress => "notifications/progress"
  | #initialized => "notifications/initialized"
  | #rootsListChanged => "notifications/roots/list_changed"
  | #tasksStatus => "notifications/tasks/status"
  | #message => "notifications/message"
  | #resourcesUpdated => "notifications/resources/updated"
  | #resourcesListChanged => "notifications/resources/list_changed"
  | #toolsListChanged => "notifications/tools/list_changed"
  | #promptsListChanged => "notifications/prompts/list_changed"
  | #elicitationComplete => "notifications/elicitation/complete"
  }

let notificationFromString = value =>
  switch value {
  | "notifications/cancelled" => #cancelled
  | "notifications/progress" => #progress
  | "notifications/initialized" => #initialized
  | "notifications/roots/list_changed" => #rootsListChanged
  | "notifications/tasks/status" => #tasksStatus
  | "notifications/message" => #message
  | "notifications/resources/updated" => #resourcesUpdated
  | "notifications/resources/list_changed" => #resourcesListChanged
  | "notifications/tools/list_changed" => #toolsListChanged
  | "notifications/prompts/list_changed" => #promptsListChanged
  | "notifications/elicitation/complete" => #elicitationComplete
  | other => JsError.throwWithMessage("Unsupported MCP notification method: " ++ other)
  }
