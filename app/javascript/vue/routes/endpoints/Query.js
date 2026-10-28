import AjaxCall from '@/helpers/ajaxCall'

const controller = 'queries'

export const Query = {
  // @param resource [String] e.g. 'collection_objects'
  sortableColumns: (resource) =>
    AjaxCall('get', `/${controller}/${resource}/sortable_columns.json`)
}
