import baseCRUD from './base'

const permitParams = {
  combination: Object
}

export const Combination = {
  ...baseCRUD('combinations', permitParams)
}
