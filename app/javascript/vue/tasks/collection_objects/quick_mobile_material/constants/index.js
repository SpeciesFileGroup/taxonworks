export const TASK_TOKEN_STATE = {
  Pending: 'pending',
  Active: 'active'
}

// Displayed status of the task_token, see store getter `status`
export const STATUS = {
  NotStarted: 'Not started',
  Waiting: 'Waiting for scan',
  Connected: 'Connected',
  Expired: 'Expired',
  Invalidated: 'Invalidated'
}
