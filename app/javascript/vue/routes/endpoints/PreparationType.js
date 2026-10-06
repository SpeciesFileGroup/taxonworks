import baseCRUD from './base'

const permitParams = {
  preparation_type: {
    name: String,
    definition: String
  }
}

export const PreparationType = {
  ...baseCRUD('preparation_types', permitParams)
}
