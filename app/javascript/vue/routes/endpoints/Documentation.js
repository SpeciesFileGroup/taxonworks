import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'documentation'
const permitParams = {
  documentation: {
    documentation_object_id: Number,
    documentation_object_type: String,
    document_id: Number,
    annotated_global_entity: String,
    position: Number,
    document_attributes: {
      document_file: String,
      is_public: Boolean
    }
  }
}

export const Documentation = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params)
}
