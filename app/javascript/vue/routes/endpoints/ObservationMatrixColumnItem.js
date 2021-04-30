import baseCRUD, { annotations } from './base'

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
  ...baseCRUD('observation_matrix_column_items', permitParams),
  ...annotations('observation_matrix_column_items')
}
