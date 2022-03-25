import AjaxCall from 'helpers/ajaxCall'
import baseCRUD, { annotations } from './base'

const controller = 'observation_matrix_column_items'
const permitParams = {
  observation_matrix_column_item: {
    controlled_vocabulary_term_id: Number,
    observation_matrix_id: Number,
    type: String,
    descriptor_id: Number,
    keyword_id: Number,
    position: Number
  }
}

export const ObservationMatrixColumnItem = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  createBatch: (params) => AjaxCall('post', `/${controller}/batch_create`, params)
}
