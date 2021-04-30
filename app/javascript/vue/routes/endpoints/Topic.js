import baseCRUD from './base'

const permitParams = {
  topic: {}
}

export const Topic = {
  ...baseCRUD('topics', permitParams)
}
