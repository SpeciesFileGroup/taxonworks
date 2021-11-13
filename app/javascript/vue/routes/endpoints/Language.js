import baseCRUD from './base'

const permitParams = {
  language: Object
}

export const Language = {
  ...baseCRUD('languages', permitParams)
}
