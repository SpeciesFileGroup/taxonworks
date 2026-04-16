import baseCRUD from './base'

const permitParams = {
  preparation_type: {
    name: String,
    definition: String
  }
}

const controller = 'preparation_types'
export const PreparationType = {
  ...baseCRUD('preparation_types', permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params),
}
