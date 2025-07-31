import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'documents'
const permitParams = {
  document: {
    document_file: String,
    initialize_start_page: String,
    is_public: Boolean
  }
}

export const Document = {
  ...baseCRUD('documents', permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params),
  file_extensions: () => AjaxCall('get', `/${controller}/file_extensions`)
}
