import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'news'

const permitParams = {
  news: {
    id: Number,
    type: String,
    title: String,
    body: String,
    is_public: Boolean,
    display_start: String,
    display_end: String
  }
}

export const News = {
  ...baseCRUD(controller, permitParams),

  administration: () => AjaxCall('get', `/${controller}/administration`),

  types: () => AjaxCall('get', `/${controller}/types`)
}
