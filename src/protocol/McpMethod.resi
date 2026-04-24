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

let requestToString: request => string
let requestFromString: string => request
let notificationToString: notification => string
let notificationFromString: string => notification
