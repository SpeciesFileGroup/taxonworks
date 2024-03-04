import AjaxCall from '@/helpers/ajaxCall'

const controller = 'metadata'

export const Metadata = {
  relatedSummary: (params) =>
    AjaxCall('post', `/${controller}/related_summary`, params),

  dataModels: () => AjaxCall('get', `/${controller}/data_models`),

  annotators: () => AjaxCall('get', `/${controller}/annotators`),

  vocabulary: (params) =>
    AjaxCall('get', `/${controller}/vocabulary`, { params }),

  attributes: (params) =>
    AjaxCall('get', `/${controller}/attributes`, { params })
}
