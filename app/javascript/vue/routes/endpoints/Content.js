import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const permitParams = {
  content: {
    text: String,
    otu_id: Number,
    topic_id: Number,
    is_public: Boolean
  }
}

export const Content = {
  ...baseCRUD('contents', permitParams),
  ...annotations('contents'),

  summary: () => AjaxCall('get', '/tasks/content/publisher/summary'),

  publishAll: (topicId) => AjaxCall('post', '/tasks/content/publisher/publish_all', { topic_id: topicId }),

  unpublishAll: (topicId) => AjaxCall('post', '/tasks/content/publisher/unpublish_all', { topic_id: topicId }),

  topicTable: (params) => AjaxCall('get', '/tasks/content/publisher/topic_table', { params })
}
