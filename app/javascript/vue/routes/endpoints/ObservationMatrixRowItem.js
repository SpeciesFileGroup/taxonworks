import baseCRUD, { annotations } from './base'

const permitParams = {
  observation_matrix_row_item: {
    observation_matrix_id: Number,
    observation_object_id: Number,
    observation_object_type: String,
    type: String,
    taxon_name_id: Number,
    position: Number
  }
}

export const ObservationMatrixRowItem = {
  ...baseCRUD('observation_matrix_row_items', permitParams),
  ...annotations('observation_matrix_row_items')
}
