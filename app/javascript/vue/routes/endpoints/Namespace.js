import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'namespaces'

const permitParams = {
  namespace: {
    id: Number,
    institution: String,
    name: String,
    short_name: String,
    verbatim_short_name: String,
    delimiter: String,
    is_virtual: Boolean
  }
}

export const Namespace = {
  ...baseCRUD('namespaces', permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params)
}
